import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project3/login/login.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const MaterialApp(
    home: Signup_nickname(id: '', password: '', name: '', birth: '', address: '', phone: '', email: ''),
  ));
}

const MaterialColor customSwatch = MaterialColor(
  0xFFEA5550,
  <int, Color>{
    50: Color(0xFFFFEDEE),
    100: Color(0xFFFFD0D1),
    200: Color(0xFFFFB1B3),
    300: Color(0xFFFF9194),
    400: Color(0xFFFF7C7F),
    500: Color(0xFFEA5550),
    600: Color(0xFFD84948),
    700: Color(0xFFC53C3A),
    800: Color(0xFFB12E2C),
    900: Color(0xFF9E2020),
  },
);

class Signup_nickname extends StatefulWidget {
  final String id;
  final String password;
  final String name;
  final String birth;
  final String address;
  final String phone;
  final String email;

  const Signup_nickname({
    super.key,
    required this.id,
    required this.password,
    required this.name,
    required this.birth,
    required this.address,
    required this.phone,
    required this.email,
  });

  @override
  State<Signup_nickname> createState() => _Signup_nicknameState();
}

class _Signup_nicknameState extends State<Signup_nickname> {
  final TextEditingController _nicknameController = TextEditingController();

  // 비밀번호 해시화 함수
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // 비밀번호를 바이트로 변환
    var digest = sha256.convert(bytes); // SHA-256 해시 적용
    return digest.toString(); // 해시된 문자열 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 50)),
            Form(
              child: Theme(
                data: ThemeData(
                  primaryColor: Colors.grey,
                  inputDecorationTheme: const InputDecorationTheme(
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(40.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '가명을 입력해주세요 :)',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '마지막 단계에요!',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(100, 48, 48, 48),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nicknameController,
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () async {
                                // 사용자가 입력한 가명
                                final nickname = _nicknameController.text.trim();

                                // 입력값이 비어있는지 확인
                                if (nickname.isEmpty) {
                                  // 닉네임이 입력되지 않은 경우: 경고 메시지 표시
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('가명 입력 필요'),
                                        content: const Text('가명을 입력해 주세요.'),
                                        actions: [
                                          TextButton(
                                            child: const Text('닫기'),
                                            onPressed: () {
                                              Navigator.of(context).pop(); // 알림 창을 닫습니다.
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return; // 입력값이 없으므로 아래 로직을 실행하지 않습니다.
                                }

                                // Supabase를 사용하여 중복 체크 쿼리 실행
                                final response = await Supabase.instance.client
                                    .from('users') // 'users'는 테이블 이름
                                    .select()
                                    .eq('user_nickname', nickname) // 'user_nickname' 열이 입력된 'nickname'과 같은지 확인
                                    .maybeSingle(); // 단일 결과를 기대하는 경우에 사용

                                if (response == null || response.isEmpty) {
                                  // 나이 계산 (생년월일 기준)
                                  final birthYear = int.parse(widget.birth.split('-')[0]); // -를 기준으로 배열을 만들고 그 중 첫번째 값
                                  final currentYear = DateTime.now().year;
                                  final age = currentYear - birthYear;

                                  // 나이에 따라 user_gubun 설정
                                  final userGubun = age >= 65 ? 1 : 2;

                                  String formatDateString(String dateString) {
                                    // 날짜 문자열을 '-'를 기준으로 분리
                                    final parts = dateString.split('-');

                                    // 연, 월, 일을 각각 가져오기
                                    final year = parts[0];
                                    // padLeft(2, '0') = 문자열이 2자리보다 적으면 왼쪽에 0을 붙임
                                    final month = parts[1].padLeft(2, '0'); // 월을 두 자리로 만들기
                                    final day = parts[2].padLeft(2, '0'); // 일을 두 자리로 만들기

                                    // 새로운 형식의 날짜 문자열 반환
                                    return '$year-$month-$day';
                                  }

                                  final formattedBirth = formatDateString(widget.birth); // 날짜 형식을 올바르게 조정
                                  String formattedCurrentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 날짜 형식을 변경

                                  // 비밀번호 해시화
                                  final hashedPassword = hashPassword(widget.password);

                                  final insertResponse = await Supabase.instance.client
                                      .from('users')
                                      .insert({
                                    'user_id': widget.id,
                                    'user_password': hashedPassword, // 해시된 비밀번호 저장
                                    'user_name': widget.name,
                                    'user_birth': formattedBirth, // 형식이 조정된 날짜 사용
                                    'user_address': widget.address,
                                    'user_phone': widget.phone,
                                    'user_email': widget.email,
                                    'user_nickname': nickname,
                                    'user_gubun': userGubun,
                                    'user_date': formattedCurrentDate, // yyyy-MM-dd 형식의 현재 날짜
                                  })
                                      .select();

                                  // 삽입이 성공하면 알림을 표시하고 로그인 페이지로 이동
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('회원가입 완료'),
                                        content: const Text('회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.'),
                                        actions: [
                                          TextButton(
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop(); // AlertDialog를 닫습니다.
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => login(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // 닉네임이 중복된 경우: 알림 창 표시
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('중복된 가명'),
                                        content: const Text('입력하신 가명이 이미 존재합니다. 다른 가명을 사용해주세요.'),
                                        actions: [
                                          TextButton(
                                            child: const Text('닫기'),
                                            onPressed: () {
                                              Navigator.of(context).pop(); // 알림 창을 닫습니다.
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customSwatch,
                                minimumSize: const Size(100, 50),
                              ),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
