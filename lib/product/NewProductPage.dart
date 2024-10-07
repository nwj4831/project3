import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위해 추가
import 'package:project3/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase를 사용하기 위해 추가
import 'dart:typed_data'; // Uint8List를 사용하기 위해 추가

class NewProductPage extends StatefulWidget {
  const NewProductPage({Key? key}) : super(key: key);

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController =
      TextEditingController(); // 가격 입력 필드 추가
  String? selectedCategory;
  String? mainImageUrl;
  String? detailImageUrl;

  final SupabaseClient supabase = Supabase.instance.client;

  // 대표 이미지 업로드
  Future<void> uploadMainImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final Uint8List imageBytes = await image.readAsBytes();
    final mainImagePath =
        'main/${DateTime.now().millisecondsSinceEpoch}_${image.name}'; // 시간 추가

    // MIME 타입 결정
    String contentType = 'image/jpeg'; // 기본값으로 설정
    if (image.path.endsWith('.png')) {
      contentType = 'image/png';
    } else if (image.path.endsWith('.gif')) {
      contentType = 'image/gif';
    }

    try {
      await supabase.storage.from('product_main_img').uploadBinary(
            mainImagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true, // 중복 파일 허용
              contentType: contentType, // Content-Type 설정
            ),
          );

      String uploadedMainImageUrl =
          supabase.storage.from('product_main_img').getPublicUrl(mainImagePath);
      uploadedMainImageUrl = Uri.parse(uploadedMainImageUrl).replace(
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString()
          }).toString();

      setState(() {
        mainImageUrl = uploadedMainImageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대표 이미지 업로드 실패: $e')),
      );
    }
  }

  // 상세 이미지 업로드
  Future<void> uploadDetailImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final Uint8List imageBytes = await image.readAsBytes();
    final detailImagePath =
        'detail/${DateTime.now().millisecondsSinceEpoch}_${image.name}'; // 시간 추가

    // MIME 타입 결정
    String contentType = 'image/jpeg'; // 기본값으로 설정
    if (image.path.endsWith('.png')) {
      contentType = 'image/png';
    } else if (image.path.endsWith('.gif')) {
      contentType = 'image/gif';
    }

    try {
      await supabase.storage.from('product_main_img').uploadBinary(
            detailImagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true, // 중복 파일 허용
              contentType: contentType, // Content-Type 설정
            ),
          );

      String uploadedDetailImageUrl = supabase.storage
          .from('product_main_img')
          .getPublicUrl(detailImagePath);
      uploadedDetailImageUrl = Uri.parse(uploadedDetailImageUrl).replace(
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString()
          }).toString();

      setState(() {
        detailImageUrl = uploadedDetailImageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상세 이미지 업로드 실패: $e')),
      );
    }
  }

  // 상품 등록
  Future<void> registerProduct() async {
    try {
      final int? price = int.tryParse(priceController.text);
      if (price == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('가격을 올바르게 입력해주세요.')));
        return;
      }

      // 데이터베이스에 데이터 삽입
      final insertResponse = await supabase.from('product').insert({
        'product_title': titleController.text,
        'product_categori': selectedCategory,
        'product_image': detailImageUrl,
        'product_thumbnail': mainImageUrl,
        'price': price,
      }).select(); // 응답을 선택하는 방식으로 데이터를 받음.

      if (insertResponse == null || insertResponse.isEmpty) {
        throw '상품 등록에 실패했습니다.';
      }

      // 상품 등록 성공 시 메인 화면으로 이동
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('상품이 등록되었습니다.')));

      // 메인 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const Main()), // main.dart의 MainPage로 이동
        (Route<dynamic> route) => false, // 모든 이전 화면 제거
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('등록 중 오류 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('상품 제목'),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: '상품 제목 입력',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('카테고리'),
            DropdownButtonFormField<String>(
              items: ['식품', '생활용품', '의류', '선물용품'].map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              decoration: const InputDecoration(
                hintText: '카테고리 선택',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('가격'),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '가격 입력',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('대표 이미지'),
            ElevatedButton(
              onPressed: uploadMainImage,
              child: const Text('대표 이미지 업로드'),
            ),
            if (mainImageUrl != null)
              Image.network(
                mainImageUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16.0),
            const Text('상세 이미지'),
            ElevatedButton(
              onPressed: uploadDetailImage,
              child: const Text('상세 이미지 업로드'),
            ),
            if (detailImageUrl != null)
              Image.network(
                detailImageUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.grey,
                  height: 56,
                  alignment: Alignment.center,
                  child: const Text(
                    '뒤로가기',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 56,
              color: Colors.black,
            ),
            Expanded(
              child: GestureDetector(
                onTap: registerProduct,
                child: Container(
                  color: Colors.orange,
                  height: 56,
                  alignment: Alignment.center,
                  child: const Text(
                    '등록',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
