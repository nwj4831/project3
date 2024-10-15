import 'package:project3/signup/signup_phone.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:remedi_kopo/remedi_kopo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rtgmnhdcwuacmvlwxqoz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Z21uaGRjd3VhY212bHd4cW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0Mjk4MzEsImV4cCI6MjA0MTAwNTgzMX0.Cq5zNfZ8AKJmrR0VQlJuH2v5P5U-RAT0tK7piH_EKN4",
  );
  runApp(const MaterialApp(
    home: Signup_address(id: '', password: '', name: '', birth: ''),
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

class Signup_address extends StatefulWidget {
  final String id; // id 변수를 추가하여 아이디를 받을 수 있도록 함
  final String password; // password 변수를 추가하여 비밀번호를 받을 수 있도록 함
  final String name;
  final String birth;

  const Signup_address({super.key, required this.id, required this.password, required this.name, required this.birth}); // 생성자에서 id와 password를 필수로 받도록 함

  @override
  State<Signup_address> createState() => _Signup_addressState();
}

class _Signup_addressState extends State<Signup_address> {
  final TextEditingController _addressController = TextEditingController(); // 주소 입력 컨트롤러 추가
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _addressDetailController = TextEditingController();

  /// Form State 카카오 주소찾기 api 실행 메소드
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  Map<String, String> formData = {};

  void _searchAddress(BuildContext context) async {
    print('주소 검색 시작'); // 로그로 확인
    KopoModel? model = await Navigator.push(
      context,
      MaterialPageRoute( // CupertinoPageRoute 대신 MaterialPageRoute 사용
        builder: (context) => RemediKopo(),
      ),
    );

    if (model != null) {
      final postcode = model.zonecode ?? '';
      _postcodeController.value = TextEditingValue(
        text: postcode,
      );
      formData['postcode'] = postcode;

      final address = model.address ?? '';
      _addressController.value = TextEditingValue(
        text: address,
      );
      formData['address'] = address;

      final buildingName = model.buildingName ?? '';
      _addressDetailController.value = TextEditingValue(
        text: buildingName,
      );
      formData['address_detail'] = buildingName;
    }
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
              key: _formKey,
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
                          // 'ID: ${widget.id}, Password: ${widget.password}, Name: ${widget.name}, Birth: ${widget.birth}',
                          '주소를 입력해주세요',
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '주민등록상의 주소를 입력해주세요',
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
                                controller: _addressController,
                                onTap: () => _searchAddress(context), // TextField를 누르면 _searchAddress 호출
                                readOnly: true,
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
                                final address = _addressController.text;
                                if (_addressController.text.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('오류'),
                                        content: const Text('주소를 입력해주세요.'),
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
                                  // print('아이디: ${widget.id}, 비밀번호: ${widget.password}, 이름: ${widget.name}, 생년월일: ${widget.birth}, 주소: $address');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Signup_phone(
                                        id: widget.id,
                                        password: widget.password,
                                        name: widget.name,
                                        birth: widget.birth,
                                        address: address,
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