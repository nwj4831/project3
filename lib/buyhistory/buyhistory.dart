import 'package:flutter/material.dart';
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';
import 'package:project3/buyhistory/detail_buyhistory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Flutter Secure Storage import

class BuyHistory extends StatefulWidget {
  @override
  _BuyHistoryState createState() => _BuyHistoryState();
}

class _BuyHistoryState extends State<BuyHistory> {
  final SupabaseClient supabase = Supabase.instance.client;
  final storage =
      const FlutterSecureStorage(); // Flutter Secure Storage 인스턴스 생성
  List<dynamic> orderHistory = [];
  bool isLoading = true; // 로딩 상태를 관리할 변수

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory(); // 주문 내역 가져오기
  }

  Future<void> _fetchOrderHistory() async {
    // SecureStorage에서 user_id 가져오기
    String? userid = await storage.read(key: 'user_id');

    if (userid != null) {
      try {
        // buyhistory 테이블에서 user_id가 일치하는 데이터를 가져오기
        final List<dynamic> response = await supabase
            .from('buyhistory')
            .select() // 데이터를 선택
            .eq('user_id',
                userid) // user_id가 SecureStorage에서 가져온 사용자 ID와 일치하는 데이터 필터링
            .order('buy_id'); // 주문 ID로 정렬

        // 결과를 콘솔에 출력하여 확인
        print('가져온 데이터: $response');

        // 가져온 데이터를 상태로 설정
        setState(() {
          orderHistory = response; // 가져온 데이터를 리스트에 저장
          isLoading = false; // 로딩이 완료됨
        });
      } catch (e) {
        print('데이터를 불러오는 중 오류 발생: $e'); // 오류 발생 시 출력
        setState(() {
          isLoading = false; // 로딩 완료
        });
      }
    } else {
      print('userID를 찾을 수 없습니다.'); // user_id가 없을 때 처리
      setState(() {
        isLoading = false; // 로딩 완료
      });
    }
  }

  // book_id가 null이 아닐 때 book 테이블에서 데이터 가져오기
  Future<Map<String, dynamic>?> _fetchBookData(int bookId) async {
    final response = await supabase
        .from('book')
        .select('book_title, book_price')
        .eq('book_id', bookId)
        .maybeSingle(); // 단일 결과를 가져옴

    return response;
  }

  // book_id가 null일 때 product 테이블에서 데이터 가져오기
  Future<Map<String, dynamic>?> _fetchProductData(int productId) async {
    final response = await supabase
        .from('product')
        .select('product_title, price')
        .eq('product_id', productId)
        .maybeSingle(); // 단일 결과를 가져옴

    return response;
  }

  @override
  Widget build(BuildContext context) {
    // book_id가 null인 데이터(마일리지 결제 내역)와 null이 아닌 데이터(카드 결제 내역)를 분리
    final mileagePayments =
        orderHistory.where((order) => order['book_id'] == null).toList();
    final cardPayments =
        orderHistory.where((order) => order['book_id'] != null).toList();

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
              child: CircularProgressIndicator()) // 데이터가 로딩 중일 때 스피너 표시
          : orderHistory.isEmpty
              ? const Center(
                  child: Text(
                    '주문 내역이 없습니다.', // 주문 내역이 없을 때 표시할 텍스트
                    style: TextStyle(fontSize: 20),
                  ),
                ) // 주문 내역이 없을 때 중앙에 텍스트 표시
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 마일리지 결제 내역 섹션
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          color:
                              Color(0xFFFFEBEE), // 연한 핑크색 배경 (Colors.pink[50])
                          child: Text(
                            '  마일리지 결제 내역  ',
                            style: TextStyle(
                                fontSize: 30),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true, // 부모 Column 높이에 맞추기 위해 설정
                        physics:
                            NeverScrollableScrollPhysics(), // 스크롤이 중첩되지 않도록 설정
                        itemCount: mileagePayments.length, // 마일리지 결제 아이템 개수
                        itemBuilder: (context, index) {
                          final order = mileagePayments[index];
                          final productId = order['product_id'];

                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _fetchProductData(productId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('로딩 중...'), // 데이터가 로딩 중일 때
                                );
                              }

                              if (snapshot.hasError) {
                                return const ListTile(
                                  title:
                                      Text('데이터를 불러오는 중 오류 발생'), // 데이터 불러오기 실패
                                );
                              }

                              if (!snapshot.hasData || snapshot.data == null) {
                                return const ListTile(
                                  title: Text('데이터가 없습니다'), // 데이터가 없는 경우
                                );
                              }

                              final data = snapshot.data!;
                              final title = data['product_title'];
                              final price = data['price'];

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.5), // 하단 border
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    '$title', // 상품명 표시
                                    style: TextStyle(fontSize: 22), // 폰트 크기 조절
                                  ),
                                  subtitle: Text(
                                    '가격: $price원', // 가격 표시
                                    style: TextStyle(fontSize: 20), // 폰트 크기 조절
                                  ),
                                  onTap: () {
                                    // ListTile을 눌렀을 때 detail_buyhistory.dart로 이동하며 전체 데이터를 넘김
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailBuyHistory(
                                          data: {
                                            'title': title,
                                            'price': price,
                                            'productId':
                                                productId, // product 또는 book ID도 함께 넘김
                                            // 다른 필요한 데이터들도 추가
                                            ...order, // order에 포함된 모든 데이터도 함께 넘기기
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20), // 섹션 간 간격
                      // 카드 결제 내역 섹션
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          color:
                              Color(0xFFFFEBEE), // 연한 핑크색 배경 (Colors.pink[50])
                          child: Text(
                            '  카드 결제 내역  ',
                            style: TextStyle(
                                fontSize: 30),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true, // 부모 Column 높이에 맞추기 위해 설정
                        physics:
                            NeverScrollableScrollPhysics(), // 스크롤이 중첩되지 않도록 설정
                        itemCount: cardPayments.length, // 카드 결제 아이템 개수
                        itemBuilder: (context, index) {
                          final order = cardPayments[index];
                          final bookId = order['book_id'];

                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _fetchBookData(bookId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('로딩 중...'), // 데이터가 로딩 중일 때
                                );
                              }

                              if (snapshot.hasError) {
                                return const ListTile(
                                  title:
                                      Text('데이터를 불러오는 중 오류 발생'), // 데이터 불러오기 실패
                                );
                              }

                              if (!snapshot.hasData || snapshot.data == null) {
                                return const ListTile(
                                  title: Text('데이터가 없습니다'), // 데이터가 없는 경우
                                );
                              }

                              final data = snapshot.data!;
                              final title = data['book_title'];
                              final price = data['book_price'];

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.5), // 하단 border
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    '$title', // 상품명 표시
                                    style: TextStyle(fontSize: 22), // 폰트 크기 조절
                                  ),
                                  subtitle: Text(
                                    '가격: $price원', // 가격 표시
                                    style: TextStyle(fontSize: 20), // 폰트 크기 조절
                                  ),
                                  onTap: () {
                                    // ListTile을 눌렀을 때 detail_buyhistory.dart로 이동하며 전체 데이터를 넘김
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailBuyHistory(
                                          data: {
                                            'title': title,
                                            'price': price,
                                            // 다른 필요한 데이터들도 추가
                                            ...order, // order에 포함된 모든 데이터도 함께 넘기기
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
