import 'package:flutter/material.dart';
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';
import 'package:project3/buyhistory/detail_buyhistory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Flutter Secure Storage import

class Userbuyhistory extends StatefulWidget {
  @override
  _UserBuyHistoryState createState() => _UserBuyHistoryState();
}

class _UserBuyHistoryState extends State<Userbuyhistory> {
  final SupabaseClient supabase = Supabase.instance.client;
  final storage = const FlutterSecureStorage(); // Flutter Secure Storage 인스턴스 생성
  List<dynamic> orderHistory = [];
  bool isLoading = true; // 로딩 상태를 관리할 변수

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory(); // 주문 내역 가져오기
  }

  // 주문 내역 가져오기
  Future<void> _fetchOrderHistory() async {
    try {
      final response = await supabase.from('buyhistory').select().order('buy_id');
      setState(() {
        orderHistory = response;
        isLoading = false;
      });
    } catch (e) {
      print('데이터를 불러오는 중 오류 발생: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 테이블에서 데이터 가져오기 (book 또는 product)
  Future<Map<String, dynamic>?> _fetchData(String table, int id, List<String> columns) async {
    final response = await supabase.from(table).select(columns.join(',')).eq('${table}_id', id).maybeSingle();
    return response;
  }

  // 데이터베이스에서 항목 삭제
  Future<void> _deleteOrder(int buyId) async {
    try {
      await supabase.from('buyhistory').delete().eq('buy_id', buyId);
      setState(() {
        orderHistory.removeWhere((order) => order['buy_id'] == buyId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주문 내역이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 마일리지 결제 및 카드 결제 리스트 생성
  Widget _buildPaymentList(List<dynamic> payments, String table, String idColumn, List<String> columns) {
    return ListView.builder(
      shrinkWrap: true, // 부모 Column 높이에 맞추기 위해 설정
      physics: const NeverScrollableScrollPhysics(), // 스크롤 중첩 방지
      itemCount: payments.length, // 결제 아이템 개수
      itemBuilder: (context, index) {
        final order = payments[index];
        final itemId = order[idColumn];
        final buyId = order['buy_id']; // 삭제를 위해 buy_id 저장

        return FutureBuilder<Map<String, dynamic>?>( 
          future: _fetchData(table, itemId, columns),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(title: Text('로딩 중...'));
            }

            if (snapshot.hasError) {
              return const ListTile(title: Text('데이터를 불러오는 중 오류 발생'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const ListTile(title: Text('데이터가 없습니다'));
            }

            final data = snapshot.data!;
            final title = data[columns[0]];
            final price = data[columns[1]];

            return _buildListTile(
              title,
              price,
              order['user_id'],
              order['buy_uname'],
              order['buy_uaddress'],
              order['buy_uphone'],
              order['buy_date'],
              buyId, // 삭제를 위한 buy_id 전달
              order,
            );
          },
        );
      },
    );
  }

  // 리스트 타일 생성
  Widget _buildListTile(
    String title,
    dynamic price,
    String userId,
    String buyUname,
    String buyUaddress,
    String buyUphone,
    String buyDate,
    int buyId, // 삭제를 위한 buy_id 전달
    dynamic order,
  ) {
    final int buyEa = order['buy_ea'] ?? 1; // 주문 수량 (없을 경우 기본값 1)
    final totalPrice = buyEa * price; // 총 가격 계산

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)), // 하단 border
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 22)), // 상품명
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _deleteOrder(buyId), // 해당 항목 삭제
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('가격: $price원', style: const TextStyle(fontSize: 20)),
                ),
                Flexible(
                  child: Text('User ID: $userId', style: const TextStyle(fontSize: 16)),
                ),
                Flexible(
                  child: Text('주문자: $buyUname', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // 전화번호와 갯수를 같은 라인에 맞춤
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('전화번호: $buyUphone', style: const TextStyle(fontSize: 16)),
                ),
                Flexible(
                  child: Text('갯수: $buyEa', style: const TextStyle(fontSize: 16)), // 갯수 출력
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // 주문 날짜와 총 가격을 같은 라인에 맞춤
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('주문 날짜: $buyDate', style: const TextStyle(fontSize: 16)),
                ),
                Flexible(
                  child: Text('총 가격: $totalPrice원', style: const TextStyle(fontSize: 16)), // 총 가격 출력
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text('주소: $buyUaddress', style: const TextStyle(fontSize: 16)),
          ],
        ),
        onTap: () {
          // ListTile을 눌렀을 때 detail_buyhistory.dart로 이동하며 전체 데이터를 넘김
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailBuyHistory(data: {'title': title, 'price': price, ...order}),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // book_id가 null인 데이터(마일리지 결제 내역)와 null이 아닌 데이터(카드 결제 내역)를 분리
    final mileagePayments = orderHistory.where((order) => order['book_id'] == null).toList();
    final cardPayments = orderHistory.where((order) => order['book_id'] != null).toList();

    return Scaffold(
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // 배경을 흰색으로 설정
        title: GestureDetector(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Main())),
          child: Image.asset('assets/logo.png', height: 40),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage())),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/mypage.jpg', height: 40),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 데이터가 로딩 중일 때 스피너 표시
          : orderHistory.isEmpty
              ? const Center(child: Text('주문 내역이 없습니다.', style: TextStyle(fontSize: 20))) // 주문 내역이 없을 때
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('마일리지 결제 내역', const Color(0xFFFFEBEE)),
                      _buildPaymentList(mileagePayments, 'product', 'product_id', ['product_title', 'price']),
                      const SizedBox(height: 20),
                      _buildSectionTitle('카드 결제 내역', const Color(0xFFFFEBEE)),
                      _buildPaymentList(cardPayments, 'book', 'book_id', ['book_title', 'book_price']),
                    ],
                  ),
                ),
    );
  }

  // 섹션 타이틀 생성
  Padding _buildSectionTitle(String title, Color backgroundColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: backgroundColor,
        child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
