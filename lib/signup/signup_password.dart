import 'package:project3/signup/signup_name.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const Signup_password(id: '')); // 초기 id 값을 전달
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

class Signup_password extends StatefulWidget {
  final String id; // id 변수를 추가하여 아이디를 받을 수 있도록 함

  const Signup_password({super.key, required this.id}); // 생성자에서 id를 필수로 받도록 함

  @override
  State<Signup_password> createState() => _SignupPasswordState();
}

class _SignupPasswordState extends State<Signup_password> {
  final TextEditingController _passwordController = TextEditingController(); // 첫 번째 비밀번호 입력 컨트롤러
  final TextEditingController _confirmPasswordController = TextEditingController(); // 두 번째 비밀번호 입력 컨트롤러

  bool _showConfirmPasswordField = false; // 두 번째 TextField 표시 여부를 제어하는 상태 변수

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
                          '비밀번호 입력해주세요 :)',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '잊어버리지 않게 꼭 기억해주세요',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(100, 48, 48, 48),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        // 첫 번째 비밀번호 입력 필드와 확인 버튼
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
                                obscureText: true, // 비밀번호 입력시 숨김처리
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                // 첫 번째 필드가 비어 있는지 확인
                                if (_passwordController.text.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('오류'),
                                        content: const Text('비밀번호를 입력해주세요.'),
                                        actions: [
                                          TextButton(
                                            child: const Text('닫기'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return; // 비어 있는 경우 경고문을 띄우고 함수 종료
                                }

                                // 첫 번째 비밀번호 입력이 비어있지 않으면 두 번째 필드를 표시하도록 설정
                                setState(() {
                                  _showConfirmPasswordField = true;
                                });
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
                        // 두 번째 비밀번호 입력 필드와 확인 버튼 (조건부로 표시)
                        if (_showConfirmPasswordField)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: '비밀번호 확인',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(100, 48, 48, 48),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: customSwatch),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: customSwatch),
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              ElevatedButton(
                                onPressed: () {
                                  // 두 비밀번호가 일치하는지 확인
                                  final password = _passwordController.text;
                                  final confirmPassword = _confirmPasswordController.text;

                                  if (password.isEmpty || confirmPassword.isEmpty) {
                                    // 비밀번호가 비어있는지 확인
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('오류'),
                                          content: const Text('모든 필드를 입력해주세요.'),
                                          actions: [
                                            TextButton(
                                              child: const Text('닫기'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return; // 유효성 검사가 실패하면 함수 종료
                                  }

                                  if (password != confirmPassword) {
                                    // 두 비밀번호가 일치하지 않을 경우
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('오류'),
                                          content: const Text('비밀번호가 일치하지 않습니다. 다시 입력해주세요.'),
                                          actions: [
                                            TextButton(
                                              child: const Text('닫기'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // 비밀번호가 일치하는 경우
                                    print('아이디: ${widget.id}, 비밀번호: $password');
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) => Signup_name(
                                          id: widget.id, 
                                          password: password
                                        ),
                                      ),
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
                        const SizedBox(height: 40.0),
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