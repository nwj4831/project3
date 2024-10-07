import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // 숫자 포맷을 위해 추가
import 'package:project3/mshop.dart';
import 'package:project3/mshop/mshoppayment.dart';
import 'package:project3/models/product.dart'; // Product 클래스 import 추가

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({Key? key}) : super(key: key);

  @override
  _ShoppingcartState createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  final storage = const FlutterSecureStorage();
  String userMile = '로딩 중...';
  List<CartItem> cartItems = []; // 장바구니 아이템 리스트
  List<bool> isSelected = []; // 선택된 체크박스 상태 리스트
  bool isAllSelected = false; // 전체 선택 상태
  final NumberFormat currencyFormat = NumberFormat('#,##0원'); // 가격 포맷

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchCartItems(); // 장바구니 아이템 가져오기
  }

  // 로그인된 유저 정보 가져오기
  Future<void> _fetchUserInfo() async {
    // SecureStorage에서 user_id를 가져옴
    String? userId = await storage.read(key: 'user_id');

    if (userId != null) {
      // Supabase에서 해당 user_id의 user_mile 값을 쿼리
      final response = await Supabase.instance.client
          .from('users')
          .select('user_mile')
          .eq('user_id', userId)
          .single();

      if (response != null && response['user_mile'] != null) {
        setState(() {
          userMile = response['user_mile'].toString();
        });
      } else {
        setState(() {
          userMile = '마일리지 가져오기 오류';
        });
      }
    } else {
      setState(() {
        userMile = '로그인 필요';
      });
    }
  }

  Future<void> _fetchCartItems() async {
    String? userId = await storage.read(key: 'user_id');

    if (userId != null) {
      try {
        final response = await Supabase.instance.client
            .from('cart')
            .select('product_id')
            .eq('user_id', userId);

        if (response is PostgrestList) {
          List<CartItem> items = [];
          for (var item in response) {
            final productResponse = await Supabase.instance.client
                .from('product')
                .select('product_title, price, product_thumbnail')
                .eq('product_id', item['product_id'])
                .single();

            if (productResponse != null) {
              items.add(
                CartItem(
                  productId: item['product_id'],
                  productTitle: productResponse['product_title'],
                  price: productResponse['price'],
                  mainImage: productResponse['product_thumbnail'],
                  quantity: 1, // 기본 개수 1로 설정
                ),
              );
            }
          }
          setState(() {
            cartItems = items;
            isSelected = List<bool>.filled(cartItems.length, false); // 체크박스 초기화
          });
        } else {
          setState(() {
            cartItems = []; // 장바구니가 비어있을 때
          });
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('장바구니를 불러오는 중 오류 발생: $error')),
        );
      }
    }
  }

  // 전체 선택 또는 해제
  void _toggleAllSelection(bool? value) {
    setState(() {
      isAllSelected = value ?? false;
      isSelected = List<bool>.filled(cartItems.length, isAllSelected);
    });
  }

  // 선택한 항목들의 가격 합계를 계산
  int _calculateTotalPrice() {
    int total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (isSelected[i]) {
        total += cartItems[i].price * cartItems[i].quantity;
      }
    }
    return total;
  }

  // 구매하기 버튼 클릭 시 선택된 아이템 전달
  void _goToPaymentPage() {
    List<Product> selectedProducts = [];
    for (int i = 0; i < cartItems.length; i++) {
      if (isSelected[i]) {
        selectedProducts.add(Product(
          productNo: cartItems[i].productId,
          productName: cartItems[i].productTitle,
          productDetails: '', // 필요 시 추가
          productImageUrl: cartItems[i].mainImage,
          price: cartItems[i].price, // 원래 가격으로 변경
          quantity: cartItems[i].quantity, // 선택된 수량 추가
        ));
      }
    }

    if (selectedProducts.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MshopPaymentPage(products: selectedProducts),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 아이템이 없습니다.')),
      );
    }
  }

  // 상품 삭제 함수
  Future<void> _deleteCartItem(int index) async {
    try {
      String? userId = await storage.read(key: 'user_id');
      if (userId != null) {
        int productId = cartItems[index].productId;

        // Supabase에서 데이터 삭제 요청
        await Supabase.instance.client
            .from('cart')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);

        // 상품 삭제 후 장바구니 데이터를 다시 불러옴
        await _fetchCartItems();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상품 삭제 중 오류 발생: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('장바구니'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '마일리지: $userMile',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('장바구니가 비어 있습니다.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 체크박스
                              Checkbox(
                                value: isSelected[index], // 선택 상태
                                onChanged: (bool? value) {
                                  setState(() {
                                    isSelected[index] = value ?? false;
                                  });
                                },
                              ),
                              // 이미지
                              Image.network(
                                item.mainImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 16),
                              // 제목 및 가격
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 제목: 12글자 넘어가면 ... 처리
                                    Text(
                                      item.productTitle.length > 12
                                          ? '${item.productTitle.substring(0, 12)}...'
                                          : item.productTitle,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    // 원래 가격 표시
                                    Text(
                                        '${currencyFormat.format(item.price)} (가격)'),
                                    const SizedBox(height: 8),
                                    // 개수 선택 드롭다운
                                    DropdownButton<int>(
                                      value: item.quantity,
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          item.quantity =
                                              newValue!; // 해당 아이템의 개수 업데이트
                                        });
                                      },
                                      items: List.generate(10, (i) => i + 1)
                                          .map<DropdownMenuItem<int>>(
                                              (int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('$value개'),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              // 삭제 버튼
                              GestureDetector(
                                onTap: () {
                                  // 상품 삭제
                                  _deleteCartItem(index);
                                },
                                child: const Icon(Icons.close,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 전체 선택 및 총 가격 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      // 전체 선택 체크박스
                      Checkbox(
                        value: isAllSelected,
                        onChanged: _toggleAllSelection,
                      ),
                      const Text('전체 선택'),
                      const Spacer(),
                      // 선택된 항목들의 총 가격
                      Text(
                          '총 금액: ${currencyFormat.format(_calculateTotalPrice())}'),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: GestureDetector(
        onTap: _goToPaymentPage, // 구매하기 버튼 클릭 시 처리
        child: BottomAppBar(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                '구매하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CartItem {
  final int productId;
  final String productTitle;
  final int price;
  final String mainImage;
  int quantity; // 개수 선택 추가

  CartItem({
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.mainImage,
    required this.quantity,
  });
}
