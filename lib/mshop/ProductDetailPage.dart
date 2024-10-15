import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project3/models/product.dart';
import 'package:intl/intl.dart';
import 'package:project3/mshop/ShoppingCart.dart';
import 'package:project3/mshop/mshoppayment.dart';
import 'package:project3/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');

  ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedQuantity = 1;
  final storage = const FlutterSecureStorage();

  Future<void> addToCart() async {
    final supabase = Supabase.instance.client;
    String? userId =
        await storage.read(key: 'user_id'); // secure storage에서 user_id 읽기

    if (userId == null) {
      // 유저가 로그인하지 않은 경우 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      // product_id와 user_id가 모두 중복되는지 확인
      final existingItemResponse = await supabase
          .from('cart')
          .select()
          .eq('product_id', widget.product.productNo ?? 0) // product_id 확인
          .eq('user_id', userId) // user_id 확인
          .maybeSingle(); // 변경: maybeSingle()로 수정

      if (existingItemResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 장바구니에 추가된 상품이 있습니다.')),
        );
        return;
      }

      // 장바구니에 추가
      final response = await supabase.from('cart').insert({
        'product_id': widget.product.productNo ?? 0, // null 처리
        'user_id': userId,
      }).maybeSingle(); // 변경: maybeSingle()로 수정

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('장바구니에 추가되었습니다.')),
        );
      }
    } catch (e) {
      // 오류가 발생하면 catch 블록에서 예외를 처리합니다.
      // 추가적인 Null 체크가 필요 없으므로 오류 메시지 표시만
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장바구니 추가에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Main(),
                ),
              );
            },
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              height: 40,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Shoppingcart(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.shopping_cart, size: 30),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.product.productImageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.productName!,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "${widget.numberFormat.format(widget.product.price ?? 0)}원",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (widget.product.productDetails != null)
                Image.network(
                  widget.product.productDetails!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 150,
        child: BottomAppBar(
          child: Column(
            children: [
              Container(
                color: Colors.pink[50],
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('수량:'),
                        DropdownButton<int>(
                          value: selectedQuantity,
                          items: List.generate(10, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text('${index + 1}'),
                            );
                          }),
                          onChanged: (int? value) {
                            setState(() {
                              if (value != null) {
                                selectedQuantity = value;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Text(
                      "총 ${widget.numberFormat.format((widget.product.price ?? 0) * selectedQuantity)}원",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await addToCart();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Shoppingcart(),
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.grey,
                        height: 60,
                        alignment: Alignment.center,
                        child: const Text(
                          '장바구니 담기',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MshopPaymentPage(
                              products: [
                                Product(
                                  productNo: widget.product.productNo,
                                  productName: widget.product.productName,
                                  productDetails: widget.product.productDetails,
                                  productImageUrl:
                                      widget.product.productImageUrl,
                                  price: widget.product.price,
                                  quantity: selectedQuantity,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.orange,
                        height: 60,
                        alignment: Alignment.center,
                        child: const Text(
                          '바로구매',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
