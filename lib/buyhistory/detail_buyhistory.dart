import 'package:flutter/material.dart';
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';

class DetailBuyHistory extends StatelessWidget {
  final Map<String, dynamic> data;

  DetailBuyHistory({required this.data});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['title']}',
              style: TextStyle(fontSize: 22),
            ),
            Text(
              '가격: ${data['price']}원',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '주문자명: ${data['buy_uname']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '연락처: ${data['buy_uphone']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '배송지: ${data['buy_uaddress']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '주문 일자: ${data['buy_date']}',
              style: TextStyle(fontSize: 20),
            ),
            // 추가 데이터들을 표시할 수 있음
            // 예시로 넘긴 다른 데이터들 사용
            // Text('다른 정보: ${data['key']}'),
          ],
        ),
      ),
    );
  }
}
