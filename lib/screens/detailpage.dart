import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 가격 포맷을 위해 필요
import 'package:project3/login/login_password.dart';
import 'package:project3/main.dart';
import 'package:project3/mshop/ShoppingCart.dart';
import 'package:project3/mypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project3/models/product.dart';
import 'package:project3/screens/paymentpage.dart'; // Supabase 패키지 임포트

class DetailPage extends StatelessWidget {
  final Product product;
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');

  DetailPage({super.key, required this.product});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이미지 로딩: Supabase에서 URL을 불러와서 사용
            (product.productImageUrl != null &&
                    product.productImageUrl!.isNotEmpty)
                ? Image.network(
                    product.productImageUrl!,
                    width: 500,
                    height: 250,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    'assets/images/ex.png', // 기본 로컬 이미지
                    width: 500,
                    height: 250,
                    fit: BoxFit.fill,
                  ),
            const SizedBox(height: 16),
            Text(
              product.productName ?? '상품명 없음', // null 처리
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            const Text(
              "할머니, 할아버지의\n1년의 이야기를 담았습니다.",
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "가격: ${numberFormat.format(product.price)}원",
                  style: const TextStyle(fontSize: 25, color: Colors.black),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // 배경을 흰색으로 설정
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage(
                  product: product, // Product 객체 전달
                ), // PaymentPage로 이동
              ),
            );
          },
          child: Container(
            color: Colors.orange,
            height: 56, // 버튼의 높이
            alignment: Alignment.center,
            child: const Text(
              '구매하기',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
