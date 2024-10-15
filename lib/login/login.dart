import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../signup/signup.dart'; // signup.dart 파일을 import하여 사용
import 'login_password.dart'; // login_password.dart 파일을 import하여 사용

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const login());
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

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: customSwatch,
      ),
      home: const Login(title: ''),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key, this.title});

  final String? title;

  @override
  State<Login> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Login> {
  final TextEditingController _idController = TextEditingController(); // 아이디 컨트롤러 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0.0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 50)),
            Form(
              child: Theme(
                data: ThemeData(
                  primaryColor: Colors.grey,
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(40.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '아이디를 입력해주세요 :)',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 60.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _idController, // 컨트롤러를 아이디 입력에 사용
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                ),
                                keyboardType: TextInputType.text, // 텍스트 타입으로 변경
                              ),
                            ),
                            SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                final id = _idController.text;
                                // 버튼 클릭 시 비밀번호 입력 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPassword(
                                      id: id, // 아이디 값 전달
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customSwatch,
                                minimumSize: Size(100, 50),
                              ),
                              child: Text('확인'),
                            ),
                          ],
                        ),
                        SizedBox(height: 60.0),
                        ElevatedButton(
                          onPressed: () {
                            // 회원가입 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customSwatch, // 사각형 버튼 스타일 지정
                            minimumSize: Size(double.infinity, 60), // 버튼 크기 (폭: 화면 전체, 높이: 60)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 네모난 버튼 모양
                            ),
                          ),
                          child: Text(
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
