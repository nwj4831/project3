import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project3/buyhistory/buyhistory.dart';
import 'package:project3/main.dart';
import 'package:project3/models/product.dart';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart' as bootpay;
import 'package:project3/mypage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase 사용을 위한 패키지 임포트

class PaymentPage extends StatefulWidget {
  final Product product;

  PaymentPage({super.key, required this.product});

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');

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
              MaterialPageRoute(builder: (context) => const Main()), // main.dart의 Main으로 이동
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. 주문자 정보
              const Text(
                '1. 주문자 정보',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7F50),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  labelStyle: TextStyle(fontSize: 25), // 라벨 텍스트 크기 설정
                ),
                style: const TextStyle(fontSize: 25), // 입력 필드 텍스트 크기 설정
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  labelStyle: TextStyle(fontSize: 25), // 라벨 텍스트 크기 설정
                ),
                style: const TextStyle(fontSize: 25), // 입력 필드 텍스트 크기 설정
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '주소',
                  labelStyle: TextStyle(fontSize: 25), // 라벨 텍스트 크기 설정
                ),
                style: const TextStyle(fontSize: 25), // 입력 필드 텍스트 크기 설정
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '주소를 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // 2. 주문 내역
              const Text(
                '2. 주문 내역',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7F50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.product.productName}', // 상품 이름 자동 입력
                style: const TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 40),
              // 3. 결제 금액
              const Text(
                '3. 결제 금액',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7F50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${numberFormat.format(widget.product.price)}원', // 가격 표시
                style: const TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 40),
              // 4. 결제 방법
              const Text(
                '4. 결제 방법',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7F50),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentRoute(
                              product: widget.product,
                              userName: _nameController.text, // 입력된 이름 전달
                              userPhone: _phoneController.text, // 입력된 전화번호 전달
                              userAddress: _addressController.text, // 입력된 주소 전달
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(300, 60), // 버튼 크기
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 버튼을 네모로 설정
                      ),
                    ),
                    child: const Text(
                      '신용/체크카드 결제',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class PaymentRoute extends StatefulWidget {
  final Product product;
  final String userName; // 전달된 이름
  final String userPhone; // 전달된 전화번호
  final String userAddress; // 전달된 주소

  PaymentRoute({
    required this.product,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
  });

  _PaymentRouteState createState() => _PaymentRouteState();
}

class _PaymentRouteState extends State<PaymentRoute> {
  Payload payload = Payload();
  String _data = ""; // 서버승인을 위해 사용되기 위한 변수
  final storage =
      const FlutterSecureStorage(); // Flutter Secure Storage 인스턴스 생성
  final SupabaseClient supabase = Supabase.instance.client; // Supabase 클라이언트 생성

  String get applicationId {
    return Bootpay().applicationId('5b8f6a4d396fa665fdc2b5e7',
        '5b8f6a4d396fa665fdc2b5e8', '5b8f6a4d396fa665fdc2b5e9');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bootpayRequestDataInit(); //결제용 데이터 init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      goBootpayTest(context); // 화면이 로드되면 자동으로 결제 절차를 시작
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 결제 프로세스가 진행 중임을 알리는 로딩 표시
      ),
    );
  }

  //결제용 데이터 init
  bootpayRequestDataInit() {
    Item item1 = Item();
    item1.id = "ITEM_CODE_BOOK";
    item1.name = widget.product.productName; // Product 객체의 상품명 사용
    item1.qty = 1;
    item1.price = widget.product.price!.toDouble(); // Product 객체의 가격 사용

    payload.webApplicationId = '5b8f6a4d396fa665fdc2b5e7';
    payload.androidApplicationId = '5b8f6a4d396fa665fdc2b5e8';
    payload.iosApplicationId = '5b8f6a4d396fa665fdc2b5e9';

    payload.pg = 'danal';
    payload.method = 'card';
    payload.orderName = widget.product.productName; // Product 객체의 상품명 사용
    payload.price = widget.product.price!.toDouble(); // Product 객체의 가격 사용
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();
    payload.items = [item1];

    // 주문자 정보
    bootpay.User user = bootpay.User();
    user.username = "사용자 이름"; // 고정된 사용자 이름
    user.email = "user1234@gmail.com"; // 고정된 이메일
    user.area = "서울"; // 고정된 지역
    user.phone = "010-4033-4678"; // 고정된 전화번호
    user.addr = '서울시 동작구 상도로 222'; // 고정된 주소

    Extra extra = Extra();
    extra.appScheme = 'bootpayFlutterExample';

    payload.user = user;
    payload.extra = extra;
  }

  //버튼클릭시 부트페이 결제요청 실행
  void goBootpayTest(BuildContext context) {
    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onCancel: $data');
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출

        // 결제 완료 후 특정 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BuyHistory()), // SuccessPage로 이동
        );
      },

      onConfirm: (String data) {
        // 서버승인(클라이언트 승인 X) return false; 후에 서버에서 결제승인 수행
        checkQtyFromServer(data);
        return false;
      },
      onDone: (String data) {
        print('------- onDone: $data');
        savePaymentHistory(); // 결제 완료 후 결제 내역 저장

        // 결제 완료 후 특정 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BuyHistory()), // SuccessPage로 이동
        );
      },
    );
  }

// 결제 내역을 buyhistory 테이블에 저장하는 함수
  Future<void> savePaymentHistory() async {
    try {
      // Flutter Secure Storage에서 user_id 가져오기
      String? userId = await storage.read(key: 'user_id');
      if (userId == null) {
        print('User ID not found in storage.');
        return;
      }

      // 현재 날짜를 yyyy-mm-dd 형식으로 변환
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // buyhistory 테이블에 삽입할 데이터
      final response = await supabase.from('buyhistory').insert({
        'book_id': widget.product.productNo, // product 객체의 productNo
        'user_id': userId, // Storage에서 가져온 user_id
        'buy_uname': widget.userName, // 전달된 사용자 이름
        'buy_uphone': widget.userPhone, // 전달된 사용자 전화번호
        'buy_uaddress': widget.userAddress, // 전달된 사용자 주소
        'buy_date': currentDate, // 현재 날짜
      });

      // response가 null이 아닌지 먼저 체크한 후 오류 처리
      if (response != null && response.error != null) {
        print('Error inserting buy history: ${response.error?.message}');
      } else if (response != null) {
        print('Payment history saved successfully.');
      } else {
        print('Unexpected error: response is null.');
      }
    } catch (e) {
      print('Error saving payment history: $e');
    }
  }

  // 서버에서 재고 확인 후 결제 승인
  Future<void> checkQtyFromServer(String data) async {
    print('checkQtyFromServer http call');
    Bootpay().transactionConfirm();
  }
}
