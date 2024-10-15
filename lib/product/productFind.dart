import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductFind extends StatefulWidget {
  const ProductFind({Key? key}) : super(key: key);

  @override
  _ProductFindState createState() => _ProductFindState();
}

class _ProductFindState extends State<ProductFind> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<dynamic> _products = [];
  List<int> _selectedProducts = []; // 체크된 제품 ID 목록
  int _currentPage = 1;
  final int _itemsPerPage = 10; // 한 페이지당 표시할 항목 수
  bool _isLoading = false;
  int _totalPages = 1; // 총 페이지 수

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadTotalProducts(); // 총 상품 수를 계산해 페이지 수 설정
  }

  // 총 상품 수 조회하여 페이지 수 계산
  Future<void> _loadTotalProducts() async {
    try {
      // 상품 총 갯수 계산
      final countResponse = await _supabaseClient
          .from('product')
          .select('product_id'); // 상품 ID만 가져와서 총 개수 확인

      final totalCount = countResponse.length; // 전체 갯수 계산
      setState(() {
        _totalPages = (totalCount / _itemsPerPage).ceil(); // 총 페이지 수 계산
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('총 상품 수 조회 실패: $error')),
      );
    }
  }

  // 상품 목록 조회
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 페이지네이션을 위해 limit과 offset 사용
      final response = await _supabaseClient.from('product').select('*').range(
          (_currentPage - 1) * _itemsPerPage, _currentPage * _itemsPerPage - 1);

      setState(() {
        _products = response ?? [];
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상품 조회 실패: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 페이지 이동
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _loadProducts();
    });
  }

  // 체크박스 선택/해제 처리
  void _toggleSelection(int productId) {
    setState(() {
      if (_selectedProducts.contains(productId)) {
        _selectedProducts.remove(productId); // 이미 선택되어 있으면 해제
      } else {
        _selectedProducts.add(productId); // 선택되지 않았으면 선택
      }
    });
  }

  // 선택한 상품 삭제
  Future<void> _deleteSelected() async {
    try {
      for (int productId in _selectedProducts) {
        await _supabaseClient
            .from('product')
            .delete()
            .eq('product_id', productId);
      }

      // 삭제 후 새로고침
      _selectedProducts.clear();
      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택된 항목이 삭제되었습니다.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $error')),
      );
    }
  }

  // 수정 버튼을 눌렀을 때 실행할 함수
  void _editProduct(int productId) {
    // 수정 화면으로 이동하는 로직을 여기에 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('상품 ID $productId 수정 화면으로 이동')),
    );
  }

  // 페이지 번호 생성
  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];
    int startPage = ((_currentPage - 1) ~/ 10) * 10 + 1;
    int endPage = (startPage + 9).clamp(1, _totalPages);

    for (int i = startPage; i <= endPage; i++) {
      buttons.add(
        TextButton(
          onPressed: () => _goToPage(i),
          style: TextButton.styleFrom(
            backgroundColor: i == _currentPage ? Colors.grey[300] : null,
          ),
          child: Text('$i'),
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 조회'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedProducts.isNotEmpty ? _deleteSelected : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // 각 행에 테두리 추가
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: _selectedProducts
                                .contains(product['product_id']),
                            onChanged: (bool? value) {
                              _toggleSelection(product['product_id']);
                            },
                          ),
                          title: Text(product['product_title']),
                          subtitle: Text('가격: ${product['price']}원'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _editProduct(product['product_id']), // 수정 버튼 추가
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _currentPage > 1
                          ? () => _goToPage(_currentPage - 1)
                          : null,
                      child: const Text('이전 페이지'),
                    ),
                    ..._buildPageButtons(),
                    TextButton(
                      onPressed: _currentPage < _totalPages
                          ? () => _goToPage(_currentPage + 1)
                          : null,
                      child: const Text('다음 페이지'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
