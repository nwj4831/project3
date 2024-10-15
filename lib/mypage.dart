import 'package:flutter/material.dart';
import 'package:project3/buyhistory/buyhistory.dart';
import 'package:project3/buyhistory/userbuyhistory.dart'; // 모든 유저의 주문내역 화면
import 'package:project3/screens/bestupload.dart';
import 'main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import
import 'package:project3/login/login.dart';
import 'package:project3/diary/diaryRankingPage.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final storage = FlutterSecureStorage();
  final supabase = Supabase.instance.client;
  String? userGubun; // user_gubun 값을 저장할 변수
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    _fetchUserGubun(); // user_gubun 가져오기
  }

  // user_gubun 가져오기 함수
  Future<void> _fetchUserGubun() async {
    // FlutterSecureStorage에서 user_id 가져오기
    String? userId = await storage.read(key: 'user_id');

    if (userId != null) {
      try {
        // Supabase에서 user_id와 일치하는 user_gubun 가져오기
        final response = await supabase
            .from('users')
            .select('user_gubun')
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null && response['user_gubun'] != null) {
          setState(() {
            userGubun = response['user_gubun'].toString();
            isLoading = false; // 로딩 완료
          });
        } else {
          print('user_gubun을 찾을 수 없습니다.');
          setState(() {
            isLoading = false; // 로딩 완료
          });
        }
      } catch (e) {
        print('데이터를 가져오는 중 오류 발생: $e');
        setState(() {
          isLoading = false; // 로딩 완료
        });
      }
    } else {
      print('user_id를 찾을 수 없습니다.');
      setState(() {
        isLoading = false; // 로딩 완료
      });
    }
  }

  Future<void> _logout() async {
    await storage.delete(key: 'user_id'); // flutter_secure_storage에 저장된 값 삭제
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    ); // 로그아웃 후 로그인 화면으로 이동
  }

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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // 로딩 중일 때 스피너 표시
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter, // 버튼을 화면 상단 중앙에 배치
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20), // 상단 여백 설정
                    child: ElevatedButton(
                      onPressed: () {
                        if (userGubun == '3') {
                          // user_gubun이 3이면 모든 유저의 주문내역 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Userbuyhistory()),
                          );
                        } else {
                          // user_gubun이 1 또는 2이면 개인 주문내역 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BuyHistory()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE), // 연한 핑크색 배경
                        minimumSize: const Size(300, 80), // 넉넉한 버튼 크기 (넓이, 높이)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // 버튼을 네모로 설정
                        ),
                      ),
                      child: Text(
                        userGubun == '3' ? '모든 유저의 주문내역' : '내 주문내역 보기',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                if (userGubun == '3') // userGubun이 '3'일 때만 "인기 일기 순위" 버튼을 표시
                  Padding(
                    padding: const EdgeInsets.only(top: 20), // 상단 여백 설정
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DiaryRankingPage()), // DiaryRankingPage로 이동
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFEBEE), // 연한 핑크색 배경
                            minimumSize:
                                const Size(300, 80), // 넉넉한 버튼 크기 (넓이, 높이)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 버튼을 네모로 설정
                            ),
                          ),
                          child: const Text(
                            '인기 일기 순위',
                            style: TextStyle(fontSize: 24, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20), // 두 버튼 사이에 간격 추가
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BestUpload()), // BestUpload로 이동
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFEBEE), // 연한 핑크색 배경
                            minimumSize:
                                const Size(300, 80), // 넉넉한 버튼 크기 (넓이, 높이)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 버튼을 네모로 설정
                            ),
                          ),
                          child: const Text(
                            '베스트셀러 등록하기',
                            style: TextStyle(fontSize: 24, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),
                // 로그아웃 버튼
                GestureDetector(
                  onTap: _logout,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red, // 로그아웃 버튼의 색상
                        decoration: TextDecoration.underline, // 밑줄 추가
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
