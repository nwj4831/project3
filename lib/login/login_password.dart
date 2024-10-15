import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project3/signup/signup.dart'; // signup.dart 파일을 import하여 사용
import 'login.dart';
import 'package:project3/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const MyApp());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'login',
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: customSwatch,
      ),
      home: const LoginPassword(id: ''), // 초기 아이디 값을 전달해줍니다.
    );
  }
}

class LoginPassword extends StatefulWidget {
  final String id; // 아이디 변수를 final로 선언

  const LoginPassword({Key? key, required this.id}) : super(key: key); // 생성자에서 id를 required로 명시

  @override
  State<LoginPassword> createState() => _LoginPasswordState();
}

class _LoginPasswordState extends State<LoginPassword> {
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage(); // Secure storage 인스턴스 생성

  // 비밀번호 해시화 함수
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // 비밀번호를 바이트로 변환
    var digest = sha256.convert(bytes); // SHA-256 해시 적용
    return digest.toString(); // 해시된 문자열 반환
  }

  Future<void> _checkCredentials() async {
    final id = widget.id; // 전달된 아이디
    final password = _passwordController.text; // 사용자가 입력한 비밀번호
    final hashedPassword = hashPassword(password); // 비밀번호를 해시화

    try {
      if (id == 'admin' && password == '1234') {
        print('관리자 로그인 성공');
        await secureStorage.write(key: 'isLoggedIn', value: 'true');
        await secureStorage.write(key: 'user_id', value: id); // user_id 저장

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Main(),
          ),
        );
      } else {
        // Supabase에서 user_id와 해시된 비밀번호 비교
        final response = await Supabase.instance.client
            .from('users')
            .select()
            .eq('user_id', id)
            .eq('user_password', hashedPassword) // 해시된 비밀번호와 비교
            .maybeSingle();

        if (response == null || response.isEmpty) {
          print('로그인 실패');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('알림'),
                content: const Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
                actions: [
                  TextButton(
                    child: const Text('닫기'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('로그인 성공');
          await secureStorage.write(key: 'isLoggedIn', value: 'true');
          await secureStorage.write(key: 'user_id', value: id);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Main(),
            ),
          );
        }
      }
    } catch (e) {
      print('오류가 발생했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 입력'),
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
                          '비밀번호 입력해주세요 :)',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 60.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                ),
                                obscureText: true, // 비밀번호 입력 시 텍스트 숨김 처리
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: _checkCredentials,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customSwatch,
                                minimumSize: const Size(100, 50),
                              ),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60.0), // 비밀번호 입력 필드 아래 공간 추가
                        ElevatedButton(
                          onPressed: () {
                            // 회원가입 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customSwatch, // 사각형 버튼 스타일 지정
                            minimumSize: const Size(double.infinity, 60), // 버튼 크기
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 네모난 버튼 모양
                            ),
                          ),
                          child: const Text(
                            '회원가입하기',
                            style: TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                        ),
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
