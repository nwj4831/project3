import 'package:project3/signup/signup_nickname.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const MaterialApp(
    home: Signup_email(id: '', password: '', name: '', birth: '', address: '', phone: ''),
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

class Signup_email extends StatefulWidget {
  // 사용자 정보를 전달받기 위한 매개변수들
  final String id;
  final String password;
  final String name;
  final String birth;
  final String address;
  final String phone;
  const Signup_email({
    super.key,
    required this.id,
    required this.password,
    required this.name,
    required this.birth,
    required this.address,
    required this.phone,
  });

  @override
  State<Signup_email> createState() => _Signup_emailState();
}

class _Signup_emailState extends State<Signup_email> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _isCodeSent = false;

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showDialog('오류', '이메일을 입력해주세요.');
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'flowertalk://signup_email',
      );

      setState(() {
        _isCodeSent = true; // 인증 코드가 발송됨
      });
      _showDialog('성공', '인증 코드가 이메일로 발송되었습니다. 코드를 입력해주세요.');
    } on AuthException catch (e) {
      _showDialog('오류', e.message);
    } catch (e) {
      _showDialog('오류', e.toString());
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final verificationCode = _verificationCodeController.text.trim();

    if (verificationCode.isEmpty) {
      _showDialog('오류', '인증 코드를 입력해주세요.');
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: verificationCode,
        type: OtpType.email,
      );

      if (response.user != null) {
        _showDialog('성공', '인증이 완료되었습니다.');
        print('아이디: ${widget.id}, 비밀번호: ${widget.password}, 이름: ${widget.name}, 생년월일: ${widget.birth},주소: ${widget.address},전화번호: ${widget.phone},이메일: $email');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) => Signup_nickname(
              id: widget.id,
              password: widget.password,
              name: widget.name,
              birth: widget.birth,
              address: widget.address,
              phone: widget.phone,
              email: email,

            )
          ),
        );
      } else {
        _showDialog('오류', '알 수 없는 오류가 발생했습니다.');
      }
    } on AuthException catch (e) {
      _showDialog('오류', e.message);
    } catch (e) {
      _showDialog('오류', e.toString());
    }
  }
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('닫기'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '이메일을 입력해주세요 :)',
                style: TextStyle(
                  fontSize: 29.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
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
                    onPressed: _sendVerificationCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customSwatch,
                      minimumSize: const Size(100, 50),
                    ),
                    child: const Text('코드 전송'),
                  ),
                ],
              ),
              if (_isCodeSent) ...[
                const SizedBox(height: 20.0),
                const Text(
                  '이메일로 발송된 인증 코드를 입력해주세요',
                  style: TextStyle(
                    fontSize: 29.0,
                    color: Color.fromARGB(100, 48, 48, 48),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _verificationCodeController,
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
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customSwatch,
                        minimumSize: const Size(100, 50),
                      ),
                      child: const Text('코드 확인'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}