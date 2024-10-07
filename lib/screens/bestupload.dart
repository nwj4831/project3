import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지 추가
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // File 사용을 위한 패키지

class BestUpload extends StatefulWidget {
  @override
  _BestUploadState createState() => _BestUploadState();
}

class _BestUploadState extends State<BestUpload> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage; // 선택한 이미지를 저장할 변수

  final SupabaseClient supabase = Supabase.instance.client; // Supabase 클라이언트 생성

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // 선택된 이미지 저장
      });
    }
  }

// 이미지 업로드 함수
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes(); // 이미지 파일을 바이트로 읽기
      final fileName =
          'book_images/${DateTime.now().millisecondsSinceEpoch}.png'; // 파일명 생성

      // Supabase Storage에 파일 업로드
      final uploadResponse = await supabase.storage
          .from('bestseller')
          .uploadBinary(fileName, bytes);

      // 업로드 성공 시 경로 반환
      if (uploadResponse != null) {
        // 이미지의 URL 가져오기
        return supabase.storage.from('bestseller').getPublicUrl(fileName);
      } else {
        print('Error: upload failed.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> insertBook() async {
    final title = _titleController.text;
    final price = int.tryParse(_priceController.text);

    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('책의 이미지를 선택해주세요.')),
        );
        return;
      }

      try {
        // 이미지 업로드
        final imageUrl = await _uploadImage(_selectedImage!);

        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
          );
          return;
        }

        // book 테이블에 데이터 삽입
        final response = await supabase.from('book').insert({
          'book_title': title,
          'book_price': price,
          'book_image': imageUrl, // 업로드된 이미지 URL을 저장
        }).select();

        // 삽입 성공 시 처리
        if (response != null && response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드가 완료되었습니다.')),
          );

          // 성공 시 MyPage로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyPage()), // MyPage로 이동
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      } catch (e) {
        // 예외 발생 시 오류 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '책의 제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '책의 가격을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage, // 이미지 선택 버튼
                child: Text('이미지 선택하기'),
              ),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 150,
                ), // 선택한 이미지가 있으면 미리보기
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: insertBook, // 버튼을 누르면 insertBook 함수 실행
                child: Text('베스트셀러 등록하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
