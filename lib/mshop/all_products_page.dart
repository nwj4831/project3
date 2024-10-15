import 'package:flutter/material.dart';
import 'package:project3/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project3/mshop/ProductDetailPage.dart';
import 'package:intl/intl.dart';
import 'package:project3/main.dart';
import 'package:project3/mshop/ShoppingCart.dart';
import 'dart:math';

class AllProductsPage extends StatelessWidget {
  const AllProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Main(),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  height: 50,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Shoppingcart(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.shopping_cart, size: 35),
                ),
              ),
            ],
            backgroundColor: Colors.white,
            toolbarHeight: 100,
            centerTitle: true,
          ),
        ),
      ),
      body: const AllProductListPage(),
    );
  }
}

class AllProductListPage extends StatefulWidget {
  const AllProductListPage({super.key});

  @override
  State<AllProductListPage> createState() => _AllProductListPageState();
}

//페이징 부분
class _AllProductListPageState extends State<AllProductListPage> {
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');
  final int _pageSize = 10; // 페이지당 항목 수
  int _currentPage = 0; // 현재 페이지 번호
  List<Product> _productList = [];
  bool _isLoading = false;
  int _totalItems = 0; // 전체 아이템 수

  @override
  void initState() {
    super.initState();
    _fetchTotalItems(); // 전체 아이템 수 가져오기
    _fetchProducts(); // 첫 번째 페이지 데이터 가져오기
  }

  // Supabase에서 전체 아이템 수를 가져오는 함수
  Future<void> _fetchTotalItems() async {
    try {
      final response = await Supabase.instance.client
          .from('product')
          .select('product_id') // 전체 데이터를 가져옵니다.
          .then((data) => data as List<dynamic>); // 응답을 List로 변환

      setState(() {
        _totalItems = response.length; // 리스트의 길이로 전체 아이템 수를 설정
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Supabase에서 상품 데이터를 가져오는 함수
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('product')
          .select(
              'product_id, product_title, product_thumbnail, product_image, price')
          .order('product_id', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1)
          .then((data) {
        return data as List<dynamic>;
      });

      if (response.isNotEmpty) {
        final products = response.map<Product>((item) {
          return Product(
            productNo: item['product_id'],
            productName: item['product_title'],
            price: item['price'].toInt(),
            productImageUrl: item['product_thumbnail'],
            productDetails: item['product_image'],
          );
        }).toList();

        setState(() {
          _productList = products;
        });
      } else {
        // 데이터가 없을 경우 처리
        print('No products found');
      }
    } catch (e) {
      // 예외 처리
      print('Exception: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 페이지를 변경하는 함수
  void _changePage(int pageIndex) {
    if (pageIndex < 0 ||
        _isLoading ||
        pageIndex >= (_totalItems / _pageSize).ceil()) {
      return;
    }

    setState(() {
      _currentPage = pageIndex;
      _productList.clear(); // 이전 데이터 초기화
    });

    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: _productList.length,
            itemBuilder: (context, index) {
              return _buildGridItem(_productList[index]);
            },
          ),
        ),
        if (_totalItems > 0) // 전체 아이템 수가 0보다 클 경우에만 표시
          _buildPaginationControls(),
        if (_isLoading) // 로딩 중일 때만 표시
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildGridItem(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                product.productImageUrl ??
                    'https://example.com/placeholder.jpg',
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                product.productName ?? '상품명 없음',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${numberFormat.format(product.price)}원',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 페이지네이션 컨트롤 위젯
  Widget _buildPaginationControls() {
    const int pageRange = 2; // 현재 페이지를 기준으로 표시할 페이지 범위
    final int totalPages = (_totalItems / _pageSize).ceil(); // 전체 페이지 수 계산
    final int startPage = max(0, _currentPage - pageRange); // 시작 페이지 (최소 0)
    final int endPage = min(
        totalPages - 1, _currentPage + pageRange); // 끝 페이지 (최대 totalPages - 1)

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 추가 여백
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentPage > 0)
            InkWell(
              onTap: () => _changePage(0),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFAD8F),
                  border: Border.all(color: Colors.black), // 검정색 테두리 추가
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  '<<',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          for (int i = startPage; i <= endPage; i++)
            InkWell(
              onTap: () => _changePage(i),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: i == _currentPage ? Color(0xFFFFAD8F) : Colors.white,
                  border: Border.all(color: Colors.black), // 검정색 테두리 추가
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '${i + 1}', // 페이지 번호는 1부터 시작
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          if (_currentPage < totalPages - 1)
            InkWell(
              onTap: () => _changePage(totalPages - 1),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFAD8F),
                  border: Border.all(color: Colors.black), // 검정색 테두리 추가s
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  '>>',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
