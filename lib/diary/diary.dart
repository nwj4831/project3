import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'diaryview.dart'; // DiaryViewPage import
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController _textController = TextEditingController();

  File? _selectedImage; // 선택된 이미지 파일 저장 변수
  String? _imageUrl; // 이미지 URL 저장 변수

  final List<String> _emoticons = [
    '😀',
    '😂',
    '😍',
    '🥺',
    '😎',
    '🥳',
    '😜',
    '😢',
    '😅',
    '🙄',
    '😡',
    '🤔'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print('이미지를 선택하지 않았습니다.');
    }
  }

  Future<void> _uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final response = await supabase.storage.from('bucket_diary').uploadBinary(
            fileName, // 업로드할 파일 이름
            imageBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600', // 캐시 제어 설정 (선택 사항)
              upsert: false, // 이미 존재하는 경우 덮어쓰기 여부
            ),
          );
      if (response.isNotEmpty) {
        final publicURL =
            supabase.storage.from('bucket_diary').getPublicUrl(fileName);
        setState(() {
          _imageUrl = publicURL;
        });
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
    }
  }

  Future<void> _launchYouTube() async {
    const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; // 대체할 유튜브 URL
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e'); // 오류 메시지를 출력
    }
  }

  void _showEmoticonPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이모티콘 선택'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _emoticons.map((emoticon) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _textController.text += emoticon;
                    });
                  },
                  child: Text(
                    emoticon,
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              }).toList(),
            ),
          ),
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
  }

  Future<void> _postDiary() async {
    // 일기 내용이 비어있는지 확인
    if (_textController.text.trim().isEmpty) {
      _showEmptyDiaryAlert();
      return;
    }

    // SecureStorage에서 user_id를 가져옴
    String? userID = await secureStorage.read(key: 'user_id');

    if (userID == null) {
      print('사용자가 로그인되어 있지 않습니다.');
      return;
    } else {
      print('사용자 ID: $userID');
    }

    // 사용자의 생년월일을 가져오기
    final userResponse = await supabase
        .from('users')
        .select('user_birth')
        .eq('user_id', userID) // 현재 로그인한 사용자의 ID로 조회
        .single();

    if (userResponse == null) {
      print('사용자 정보를 찾을 수 없습니다.');
      return;
    } else {
      print('사용자 생년월일: ${userResponse['user_birth']}');
    }
    // 생년월일을 DateTime으로 변환
    DateTime userBirth = DateTime.parse(userResponse['user_birth']);
    DateTime today = DateTime.now();
    int age = today.year - userBirth.year;

    // 생일이 지나지 않았다면 나이에서 1을 뺌
    if (today.month < userBirth.month ||
        (today.month == userBirth.month && today.day < userBirth.day)) {
      age--;
    }

    // 65세 이상이면 게시글 작성 제한
    if (userBirth.year <= today.year - 65) {
      String? imageUrl; // 업로드한 이미지 URL

      // 이미지 업로드 및 URL 가져오기
      if (_selectedImage != null) {
        try {
          final pickedImageBytes =
          await _selectedImage!.readAsBytes(); // 선택된 이미지를 바이트 배열로 읽기
          String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
          await _uploadImage(pickedImageBytes, fileName);
          imageUrl = _imageUrl;
        } catch (e) {
          print('이미지 업로드 예외: $e');
          return;
        }
      }

      try {
        final response = await supabase.from('diary').insert({
          'diary_content': _textController.text,
          'diary_date': DateTime.now().toUtc().toIso8601String(),
          'diary_image': imageUrl,
          'diary_hit': 0,
          'user_id': userID, // 현재 로그인한 사용자의 ID 추가
        }).select(); // 데이터를 반환받기 위해 select() 사용

        print('Supabase 응답: $response');

        if (response.isEmpty) {
          print('데이터가 반환되지 않았습니다.');
        } else {
          print('일기가 성공적으로 게시되었습니다.');

          final insertedDiary = response[0];
          _textController.clear();
          setState(() {
            _selectedImage = null; // 게시 후 이미지 초기화
          });

          // 작성 완료 알림
          _showCompletionDialog(insertedDiary);
        }
      } catch (e) {
        print('예외 발생: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('작성 불가'),
            content: const Text('65세 미만 사용자는 게시글을 작성할 수 없습니다.'),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 알림 창 닫기
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showEmptyDiaryAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시 불가'),
          content: const Text('빈 일기는 게시할 수 없습니다.'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 알림 창 닫기
              },
            ),
          ],
        );
      },
    );
  }


  void _showCompletionDialog(Map<String, dynamic> insertedDiary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('작성 완료'),
          content: const Text('일기가 성공적으로 작성되었습니다.'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 알림 창 닫기

                // 일기 보기 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryViewPage(diary: insertedDiary),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 쓰기'),
      ),
      body: Center(
        child: Container(
          width: 768,
          height: 1500,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // 스크롤 가능하도록 수정
                    child: Column(
                      // width: double.infinity,
                      // padding: const EdgeInsets.all(16.0),
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   border: Border.all(color: Colors.black, width: 0.5),
                      // ),
                      // children: [
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.file(
                              _selectedImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        TextField(
                          // child: TextField(
                          controller: _textController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '오늘 하루 무슨 일이 있었나요?',
                            hintStyle: const TextStyle(fontSize: 20.0),
                            contentPadding: EdgeInsets.zero,
                            // ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_camera),
                      iconSize: 40,
                      onPressed: _pickImage, // 이미지 선택 함수 호출
                    ),
                    IconButton(
                      icon: const Icon(Icons.video_camera_back),
                      iconSize: 40,
                      onPressed: _launchYouTube,
                    ),
                    IconButton(
                      icon: const Icon(Icons.insert_emoticon),
                      iconSize: 40,
                      onPressed: _showEmoticonPicker,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Button pressed');
                      _postDiary();
                    },
                    child: const Text(
                      '게시하기',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
