import 'package:flutter/material.dart';
import 'package:project3/mshop/ShoppingCart.dart';
import 'package:project3/mshop/clothing_page.dart';
import 'package:project3/mshop/food_page.dart';
import 'package:project3/mshop/gift_page.dart';
import 'package:project3/mshop/living_supplies_page.dart';
import 'package:project3/mshop/all_products_page.dart'; // 전체상품 페이지 추가
import 'package:project3/main.dart';

class Mshop extends StatelessWidget {
  const Mshop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          // '전체상품' 박스
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 간격 추가
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AllProductsPage(), // 전체상품 페이지로 이동
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width, // 화면 전체 너비
                height: MediaQuery.of(context).size.height / 4, // 상단 큰 박스 높이
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAD8F), // 코랄색 배경
                  borderRadius: BorderRadius.circular(16), // 모서리 둥글게
                ),
                child: Center(
                  child: const Text(
                    '전체상품',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // '전체상품'과 그리드 사이의 간격

          // 2x2 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // 그리드 패딩 추가
              child: GridView.count(
                crossAxisCount: 2, // 2열로 설정
                crossAxisSpacing: 10, // 열 간격
                mainAxisSpacing: 10, // 행 간격
                children: [
                  _buildGridItem(
                      '식품', Color(0xFF7CD3EA), const FoodPage(), context),
                  _buildGridItem('생활용품', Color(0xFFA2EEBD),
                      const LivingSuppliesPage(), context),
                  _buildGridItem(
                      '의류', Color(0xFFF6F7C5), const ClothingPage(), context),
                  _buildGridItem(
                      '선물용', Color(0xFFF6D6D5), const GiftPage(), context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 아이템 그리드 생성 함수 (2x2 그리드용)
  Widget _buildGridItem(
      String label, Color color, Widget page, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16), // 모서리 둥글게
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
