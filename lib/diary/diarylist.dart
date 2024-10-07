import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:project3/diary/diaryview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 추가

final FlutterSecureStorage secureStorage =
    FlutterSecureStorage(); // SecureStorage 인스턴스 생성

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  _DiaryListPageState createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _diaries = [];
  bool _loading = true;
  String _errorMessage = '';
  String _currentUserId = ''; // 현재 사용자 ID

  // 댓글 리스트를 추가합니다.
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    _fetchDiaries();
    _getCurrentUserId(); // 현재 사용자 ID 가져오기
  }

    Future<void> _getCurrentUserId() async {
    // Secure Storage 또는 다른 방법으로 현재 사용자 ID 가져오기
     String? _currentUserId = await secureStorage.read(key: 'user_id');
  }

  Future<void> _fetchDiaries() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await supabase.from('diary').select();

      if (response == null || response.isEmpty) {
        setState(() {
          _errorMessage = '데이터를 가져오지 못했습니다.';
        });
      } else {
        final diaries = response as List<dynamic>;
        diaries.shuffle(Random());

        for (var diary in diaries) {
          // 각 일기에 대한 이미지 URL을 SecureStorage에서 가져오기
          final imageUrl =
              await secureStorage.read(key: 'image_url_${diary['diary_id']}');
          diary['image_url'] = imageUrl; // 이미지 URL 추가

          // 각 일기에 대한 댓글 수를 가져오기
          final commentResponse = await supabase
              .from('comment')
              .select('user_id')
              .eq('diary_id', diary['diary_id']); // diary_id로 댓글 수 조회
          diary['comment_count'] = commentResponse.length; // 댓글 수 추가
        }

        setState(() {
          _diaries = diaries.cast<Map<String, dynamic>>();
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 가져오는 도중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateLikeCount(int diaryId, int newLikeCount) async {

  try {
    // 좋아요 수를 업데이트하고, 업데이트된 데이터를 반환
    final response = await supabase
      .from('diary')
      .update({
        'diary_liked': newLikeCount
      })
      .eq('diary_id', diaryId)
      .select(); // 업데이트 후 새로운 데이터를 선택하여 반환

    if (response == null || response.isEmpty) {
      setState(() {
        _errorMessage = '데이터 업데이트 도중 오류가 발생했습니다.';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = '데이터 업데이트 도중 오류가 발생했습니다: $e';
    });
  }
}

  Future<void> _postComment(int diaryId, String commentContent) async {
    // 현재 로그인한 사용자 ID 가져오기
    String? userId = await secureStorage.read(key: 'user_id');

    if (userId == null) {
      print('사용자가 로그인하지 않았습니다.');
      return; // 로그인되지 않은 경우 처리
    }

    try {
      // 댓글 데이터베이스에 입력
      final response = await supabase.from('comment').insert({
        'diary_id': diaryId,
        'user_id': userId,
        'comment_content': commentContent,
        'comment_date': DateTime.now().toIso8601String(),
      }).select();

      print('댓글 게시 성공: $response');

      // 작성자의 user_id 가져오기
      final diaryResponse = await supabase
          .from('diary') // 다이어리 테이블 이름을 확인하여 수정할 수 있음
          .select('user_id') // 작성자 ID 가져오기
          .eq('diary_id', diaryId)
          .single();

      final authorId = diaryResponse['user_id'] as String;

      // 댓글이 작성자의 댓글 수에 따라 마일리지 적립
      if (authorId != userId) {
        await _updateUserMiles(authorId, 10); // 작성자에게 10포인트 적립
      }

      _fetchComments(diaryId); // 댓글 목록 새로 고침
    } catch (e) {
      print('댓글 게시 오류: $e');
    }
  }

// 사용자 마일리지 업데이트 함수
  Future<void> _updateUserMiles(String userId, int points) async {
    try {
      // 현재 마일리지 가져오기
      final userResponse = await supabase
          .from('users') // 사용자 테이블 이름을 확인하여 수정할 수 있음
          .select('user_mile')
          .eq('user_id', userId)
          .single();

      final currentMiles = userResponse['user_mile'] as int;

      // 마일리지 업데이트
      await supabase
          .from('users')
          .update({
            'user_mile': currentMiles + points // 기존 마일리지에 포인트 추가
          })
          .eq('user_id', userId)
          .select();

      print('마일리지 업데이트 성공');
    } catch (e) {
      print('마일리지 업데이트 오류: $e');
    }
  }

  Future<void> onDiaryTitleTap(int diaryId) async {
  try {
    // diary_id로 다이어리 데이터 조회
    final diaryData = await supabase
        .from('diary')
        .select('*')  // 모든 필드를 가져오기
        .eq('diary_id', diaryId)
        .maybeSingle();

    if (diaryData != null) {
      // 조회수 증가
      final int currentHit = diaryData['diary_hit'] ?? 0;

      await supabase
          .from('diary')
          .update({'diary_hit': currentHit + 1})
          .eq('diary_id', diaryId);

      // DiaryViewPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DiaryViewPage(diary: diaryData)), // diary 객체 전달
      );
    }
  } catch (e) {
    print('조회수 증가 중 오류 발생: $e');
  }
}

  void _showCommentDialog(int diaryId) {
    TextEditingController _commentController = TextEditingController();

    // 댓글을 가져오는 FutureBuilder를 포함한 다이얼로그
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 댓글 리스트
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchComments(diaryId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('오류: ${snapshot.error}'));
                      } else {
                        final comments = snapshot.data ?? [];

                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment['user_id'],
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold)),
                                  Text(
                                    _formatCommentDate(
                                        comment['comment_date']), // 작성 시간
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  SizedBox(height: 10.0), // 작성자와 시간 사이의 간격 // 작성자 ID
                                  Text(comment['comment_content']), // 댓글 내용
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                // 댓글 입력 필드
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '댓글 추가...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('게시'),
              onPressed: () async {
                final commentContent = _commentController.text.trim();
                if (commentContent.isNotEmpty) {
                  await _postComment(diaryId, commentContent);
                  _commentController.clear(); // 댓글 입력 필드 초기화
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  _showCommentDialog(diaryId); // 다시 다이얼로그 열기

                  // 새로운 댓글 추가
                  // final newComment = {
                  //   'user_id': 'test-user-id', // 여기서 작성자 ID를 설정
                  //   'comment_content': commentContent,
                  //   'comment_date': DateTime.now().toIso8601String(),
                  // };
                } else {
                  print('댓글 내용이 비어 있습니다.');
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<List<Map<String, dynamic>>> _fetchComments(int diaryId) async {
    try {
      final response = await supabase
          .from('comment')
          .select()
          .eq('diary_id', diaryId)
          .order('comment_date', ascending: false); // 최신 댓글이 상단에 오도록 정렬

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('댓글 가져오기 오류: $e');
      return [];
    }
  }

  String _formatCommentDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else {
      return '방금 전';
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('일기 목록'),
      backgroundColor: const Color(0xFFFFAD8F),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
            ? Center(child: Text('오류: $_errorMessage'))
            : ListView.builder(
                itemCount: _diaries.length,
                itemBuilder: (context, index) {
                  final diary = _diaries[index];
                  int _likeCount =
                        diary['diary_liked'] ?? 0; // 좋아요 카운트를 데이터에서 가져옴
                    bool _liked = _likeCount % 2 != 0;

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // diary_id와 diary_date를 위한 영역
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${diary['user_id']}', // user_id 출력
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0), // 간격 추가
                                    Text(
                                      _formatDate(diary['diary_date'] ?? ''), // 작성 시간
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14.0),
                                    ),
                                  ],
                                ),
                                // 조회수 아이콘 및 텍스트
                                // Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     const Icon(
                                //       Icons.visibility,
                                //       color: Color(0xFFFFAD8F),
                                //     ),
                                //     Text(
                                //       '${diary['diary_hit'] ?? 0}', // 조회수 출력
                                //       style: const TextStyle(
                                //         color: Colors.grey,
                                //         fontSize: 14.0,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                          // 이미지 영역
                          if (diary['diary_image'] != null) // 이미지가 있을 경우에만 표시
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.network(
                                diary['diary_image'], //이미지 URL
                                fit: BoxFit.cover, // 이미지 크기 조절
                              ),
                            ),
                          // diary_content를 위한 영역
                          ListTile(
                            contentPadding: const EdgeInsets.all(10.0),
                            title: GestureDetector(
                              onTap: () async {
                                try {
                                  // 다이어리 제목 클릭 시 조회수 증가
                                  await onDiaryTitleTap(diary['diary_id']); // 다이어리 제목 클릭 시 조회수 증가
                                } catch (e) {
                                  // 오류 발생 시 처리
                                  print('오류 발생: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('다이어리 조회 중 오류가 발생했습니다.')),
                                  );
                                }
                              },
                              child: Text(
                                diary['diary_content'] ?? '내용 없음',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            //   child: Align(
                            //     alignment: Alignment.bottomLeft,
                            //     child: Text(
                            //       _formatDate(diary['diary_date'] ?? ''),
                            //       style: const TextStyle(
                            //         color: Colors.grey,
                            //         fontSize: 14.0,
                            //         fontStyle: FontStyle.italic,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.thumb_up,
                                              color: _liked
                                                  ? Color.fromARGB(
                                                      255, 248, 104, 52)
                                                  : Color(0xFFFFAD8F),
                                            ),
                                            onPressed: () async {
                                              if (diary['diary_id'] != null) {
                                                int currentLikeCount =
                                                    diary['diary_liked'] ?? 0;
                                                bool isLiked =
                                                    currentLikeCount % 2 != 0;
                                                int newLikeCount = isLiked
                                                    ? currentLikeCount - 1
                                                    : currentLikeCount + 1;

                                                await _updateLikeCount(diary['diary_id'], newLikeCount);
                                                setState(() {
                                                  _diaries[index]
                                                          ['diary_liked'] =
                                                      newLikeCount;
                                                });

                                                // try {
                                                //   await _updateLikeCount(
                                                //       diary['diary_id'],
                                                //       newLikeCount);
                                                // } catch (e) {
                                                //   print('좋아요 업데이트 오류: $e');
                                                // }
                                              }
                                            },
                                          ),
                                          Text(
                                            '${diary['diary_liked']?? 0}',
                                            style: const TextStyle(
                                                color: Color(0xFF333333)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.comment,
                                              color: Color(0xFFFFAD8F),
                                            ),
                                            onPressed: () {
                                              _showCommentDialog(
                                                  diary['diary_id']);
                                            },
                                          ),
                                          Text(
                                            '${diary['comment_count'] ?? 0}', // 댓글 수 표시
                                            style: const TextStyle(
                                                color: Color(0xFF333333)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }


  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else {
      return '방금 전';
    }
  }
}
