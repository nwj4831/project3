import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_password.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const SignupPage());
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

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _idController = TextEditingController(); // TextEditingController 추가

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0.0,
        backgroundColor: Colors.white,
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
                        SizedBox(height: 8.0),
                        Text(
                          '사용할 아이디를 입력해 주세요',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: const Color.fromARGB(100, 48, 48, 48),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _idController, // TextEditingController 연결
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: customSwatch),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () async {
                                // 사용자가 입력한 아이디
                                final id = _idController.text.trim(); // 입력값의 공백을 제거

                                // 입력값이 비어있는지 확인
                                if (id.isEmpty) {
                                  // 아이디가 입력되지 않은 경우: 경고 메시지 표시
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('아이디 입력 필요'),
                                        content: const Text('아이디를 입력해 주세요.'),
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
                                    .from('users') // 'users'는 테이블이름
                                    .select()
                                    .eq('user_id', id) // 'user_id' 열이 입력된 'id'와 같은지 확인
                                    .maybeSingle(); // 단일 결과를 기대하는 경우에 사용

                                if (response == null || response.isEmpty) {
                                  // 아이디가 중복되지 않는 경우: 다음 화면으로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Signup_password(
                                        id: id, // 아이디 값을 전달합니다.
                                      ),
                                    ),
                                  );
                                } else {
                                  // 아이디가 중복된 경우: 알림 창 표시
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('중복된 아이디'),
                                        content: const Text('입력하신 아이디가 이미 존재합니다. 다른 아이디를 사용해주세요.'),
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
                                minimumSize: Size(100, 50),
                              ),
                              child: Text('확인'),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.0),
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