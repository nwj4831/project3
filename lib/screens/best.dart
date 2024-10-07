import 'package:flutter/material.dart';
import 'package:project3/login/login_password.dart';
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase 패키지 임포트
import 'package:intl/intl.dart';
import 'package:project3/models/product.dart';
import 'package:project3/screens/detailpage.dart';

class Best extends StatelessWidget {
  const Best({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // 배경을 흰색으로 설정
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Main()), // main.dart의 Main으로 이동
            );
          },
          child: Image.asset(
            'assets/logo.png',
            height: 40, // 로고 이미지의 높이
          ),
        ),
        centerTitle: true, // title을 중앙에 배치
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPage()), // MyPage로 이동
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/mypage.jpg',
                height: 40, // 마이페이지 이미지의 높이
              ),
            ),
          ),
        ],
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

  // Supabase에서 데이터를 가져오는 함수
  Future<List<Product>> fetchProducts() async {
    final List<dynamic> data = await Supabase.instance.client
        .from('book')
        .select(
            'book_id, book_title, book_price, book_image'); // book_image 필드를 추가

    // 데이터를 Product 객체로 변환
    return data.map((item) {
      return Product(
        productNo: int.parse(item['book_id'].toString()), // 정수형 변환
        productName: item['book_title'].toString(), // 문자열 변환
        price: int.parse(item['book_price'].toString()), // 가격을 int로 변환
        productImageUrl:
            item['book_image']?.toString() ?? '', // 업로드된 이미지 URL 사용
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
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
          return ListView.builder(
            padding: EdgeInsets.zero, // 전체 리스트의 기본 패딩 제거
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 클릭 시 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        product: productList[index],
                      ),
                    ),
                  );
                },
                child: productContainer(
                  productName: productList[index].productName ?? "",
                  productImageUrl: productList[index].productImageUrl ?? "",
                  price: productList[index].price ?? 0,
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget productContainer({
    required String productName,
    required String productImageUrl,
    required int price,
  }) {
    return Container(
      margin: const EdgeInsets.only(
          top: 25.0, left: 25.0, right: 25.0), // 컨테이너 바깥 상단, 좌측, 우측 여백 추가
      child: Column(
        mainAxisSize: MainAxisSize.min, // 남는 공간 차지하지 않도록 설정
        children: [
          // 이미지 컨테이너
          Container(
            height: MediaQuery.of(context).size.height * 0.3, // 화면 높이의 30%로 설정
            width: double.infinity, // 가로로 화면 꽉 차게 설정
            child: productImageUrl.isNotEmpty
                ? Image.network(
                    productImageUrl, // Supabase에서 가져온 이미지 URL을 사용
                    fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰 꽉 차게 설정
                  )
                : const Icon(Icons.image_not_supported), // 이미지가 없을 경우 아이콘 표시
          ),
          // 텍스트와 가격 컨테이너
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100], // 배경색은 연한 회색
            ),
            width: double.infinity, // 가로는 이미지와 맞춤
            padding: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 16), // 적절한 여백 추가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 텍스트를 가운데 정렬
              children: [
                Text(
                  productName,
                  textAlign: TextAlign.center, // 텍스트 가운데 정렬
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // 폰트 크기 확대
                  ),
                ),
                const SizedBox(height: 10), // 텍스트와 가격 사이에 간격 추가
                Text(
                  "${numberFormat.format(price)}원",
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
