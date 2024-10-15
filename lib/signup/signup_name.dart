import 'package:project3/signup/signup_birth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const MaterialApp(
    home: Signup_name(id: '', password: ''),
  )); // 초기 id와 password 값을 전달
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

class Signup_name extends StatefulWidget {
  final String id; // id 변수를 추가하여 아이디를 받을 수 있도록 함
  final String password; // password 변수를 추가하여 비밀번호를 받을 수 있도록 함

  const Signup_name({super.key, required this.id, required this.password}); // 생성자에서 id와 password를 필수로 받도록 함

  @override
  State<Signup_name> createState() => _Signup_nameState();
}

class _Signup_nameState extends State<Signup_name> {
  final TextEditingController _nameController = TextEditingController(); // 첫 번째 비밀번호 입력 컨트롤러

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
                        Text(
                          // 'ID: ${widget.id}, Password: ${widget.password}', 
                          '이름을 입력해주세요 :)',
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '주민등록상의 이름을 입력해주세요',
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
                                controller: _nameController,
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
                              onPressed: () {
                                final name = _nameController.text;
                                if (_nameController.text.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('오류'),
                                        content: const Text('이름을 입력해주세요.'),
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
                                } else {
                                  // 이름을 입력하고 확인을 누른 경우
                                  print('아이디: ${widget.id}, 비밀번호: ${widget.password}, 이름: $name');
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => Signup_birth(
                                        id: widget.id, 
                                        password: widget.password,
                                        name: name
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