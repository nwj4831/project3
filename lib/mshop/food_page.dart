import 'package:flutter/material.dart';
import 'package:project3/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase 패키지 임포트
import 'package:project3/mshop/ProductDetailPage.dart'; // ProductDetailPage 임포트
import 'package:intl/intl.dart';
import 'package:project3/main.dart';
import 'package:project3/mshop/ShoppingCart.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // AppBar의 높이를 60으로 설정
        child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // 뒤로가기 버튼 기능
                },
              ),
              title: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Main(), // Main 페이지로 이동
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/logo.png', // 로고 이미지 경로
                    fit: BoxFit.contain,
                    height: 50, // 로고 이미지 크기 조정
                  ),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Shoppingcart 페이지로 이동
                        builder: (context) => const Shoppingcart(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16.0), // 오른쪽에 여백 추가
                    child: Icon(Icons.shopping_cart, size: 35),
                  ),
                ),
              ],
              backgroundColor: Colors.white, // AppBar의 배경색을 흰색으로 설정
              toolbarHeight: 100, // AppBar의 높이 조정
              centerTitle: true, // 제목을 중앙 정렬
            )),
      ),
      body: const ItemListPage(), // ItemListPage를 메인 콘텐츠로 사용
    );
  }
}

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');

  // Supabase에서 카테고리가 "식품"인 데이터를 가져오는 함수
  Future<List<Product>> fetchProducts() async {
    final List<dynamic> data = await Supabase.instance.client
        .from('product') // 'product' 테이블에서 데이터 가져오기
        .select(
            'product_id, product_title, product_thumbnail, product_image, price') // 필요한 컬럼 선택
        .eq('product_categori', '식품'); // 'product_categori'가 '식품'인 데이터만 가져옴

    // 데이터가 리스트인 경우 처리
    return data.map((item) {
      return Product(
        productNo: item['product_id'],
        productName: item['product_title'],
        price: item['price'].toInt(),
        productImageUrl: item['product_thumbnail'], // 대표 이미지 URL 사용
        productDetails: item['product_image'], // 상세페이지 URL 사용
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: fetchProducts(), // Supabase에서 데이터를 가져옴
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 로딩 인디케이터
        } else if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('데이터가 없습니다.'));
        } else {
          final productList = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0), // 패딩 추가
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 한 행에 2개의 아이템을 보여줌
              crossAxisSpacing: 8.0, // 좌우 간격
              mainAxisSpacing: 8.0, // 상하 간격
              childAspectRatio: 0.75, // 아이템의 비율을 조정하여 이미지가 조금 더 길어짐
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return _buildGridItem(productList[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildGridItem(Product product) {
    return InkWell(
      onTap: () {
        // 클릭 시 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4.0, // 카드 그림자 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                product.productImageUrl ??
                    'https://example.com/placeholder.jpg', // null일 경우 대체 이미지 URL 제공
                fit: BoxFit.cover, // 이미지가 꽉 차게 표시
                height: 200, // 이미지 높이 설정
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0), // 상단 여백을 12.0으로 확대
              child: Text(
                product.productName ?? '상품명 없음', // null일 경우 기본값 제공
                maxLines: 1, // 한 줄로 제한
                overflow: TextOverflow.ellipsis, // 글자가 넘으면 ... 처리
                textAlign: TextAlign.center, // 텍스트 중앙 정렬
                style: const TextStyle(
                  fontSize: 18.0, // 폰트 크기를 18로 키움
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${numberFormat.format(product.price)}원', // 가격 표시
                textAlign: TextAlign.center, // 가격도 중앙 정렬
                style: TextStyle(
                  fontSize: 16.0, // 가격 폰트 크기를 16으로 키움
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 10), // 가격과 하단 간격 추가
          ],
        ),
      ),
    );
  }
}
