import 'package:flutter/material.dart';
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:project3/diary/diaryview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchDiaries();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    String? userId = await secureStorage.read(key: 'user_id');
    setState(() {
      _currentUserId = userId ?? '';
    });
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
          final commentResponse = await supabase
              .from('comment')
              .select('user_id')
              .eq('diary_id', diary['diary_id']);
          diary['comment_count'] = commentResponse.length;

          final likeResponse = await supabase
              .from('liked')
              .select()
              .eq('diary_id', diary['diary_id'])
              .eq('user_id', _currentUserId);

          diary['liked_by_current_user'] = likeResponse.isNotEmpty;

          final totalLikes = await supabase
              .from('liked')
              .select('user_id')
              .eq('diary_id', diary['diary_id']);
          diary['diary_liked'] = totalLikes.length;
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

Future<void> _postComment(
    int diaryId, String commentContent, int index) async {
  String? userId = await secureStorage.read(key: 'user_id');

  if (userId == null) {
    print('사용자가 로그인하지 않았습니다.');
    return;
  }

  try {
    // 댓글을 추가하기 전에, 해당 diary의 작성자 user_id를 가져옴
    final diaryResponse = await supabase
        .from('diary')
        .select('user_id')
        .eq('diary_id', diaryId)
        .single();

    String diaryUserId = diaryResponse['user_id'];

    // 댓글 추가
    final response = await supabase.from('comment').insert({
      'diary_id': diaryId,
      'user_id': userId,
      'comment_content': commentContent,
      'comment_date': DateTime.now().toIso8601String(),
    });

    print('댓글 게시 성공: $response');

    // 현재 사용자가 게시글 작성자가 아닐 경우 마일리지 업데이트
    if (userId != diaryUserId) {
      await _updateUserMiles(diaryUserId, 10); // 댓글 작성자에게 10 포인트 추가
    }

    await _fetchCommentsAndUpdate(diaryId, index);
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
        .eq('user_id', userId);

    print('마일리지 업데이트 성공');
  } catch (e) {
    print('마일리지 업데이트 오류: $e');
  }
}

  Future<void> _fetchCommentsAndUpdate(int diaryId, int index) async {
    try {
      final commentResponse = await supabase
          .from('comment')
          .select('user_id')
          .eq('diary_id', diaryId);

      setState(() {
        _diaries[index]['comment_count'] = commentResponse.length;
      });
    } catch (e) {
      print('댓글 수 업데이트 오류: $e');
    }
  }

  Future<void> _toggleLike(int diaryId, int index) async {
    try {
      String? userId = await secureStorage.read(key: 'user_id');
      if (userId == null) {
        print('사용자가 로그인하지 않았습니다.');
        return;
      }

      final response = await supabase
          .from('liked')
          .select()
          .eq('user_id', userId)
          .eq('diary_id', diaryId)
          .maybeSingle();

      if (response == null) {
        await supabase.from('liked').insert({
          'user_id': userId,
          'diary_id': diaryId,
        });
        setState(() {
          _diaries[index]['diary_liked'] += 1;
          _diaries[index]['liked_by_current_user'] = true;
        });
      } else {
        await supabase
            .from('liked')
            .delete()
            .eq('user_id', userId)
            .eq('diary_id', diaryId);
        setState(() {
          _diaries[index]['diary_liked'] -= 1;
          _diaries[index]['liked_by_current_user'] = false;
        });
      }
    } catch (e) {
      print('좋아요 처리 중 오류 발생: $e');
    }
  }

  Future<void> onDiaryTitleTap(int diaryId) async {
    try {
      final diaryData = await supabase
          .from('diary')
          .select('*')
          .eq('diary_id', diaryId)
          .maybeSingle();

      if (diaryData != null) {
        final int currentHit = diaryData['diary_hit'] ?? 0;

        await supabase
            .from('diary')
            .update({'diary_hit': currentHit + 1}).eq('diary_id', diaryId);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DiaryViewPage(diary: diaryData)),
        );
      }
    } catch (e) {
      print('조회수 증가 중 오류 발생: $e');
    }
  }

  void _showCommentDialog(int diaryId, int index) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: '댓글 추가...',
                ),
                maxLines: 3,
              ),
            ],
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
                  await _postComment(diaryId, commentContent, index);
                  _commentController.clear();
                  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black, // Set the color of the back button
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Main()),
            );
          },
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Main()),
            );
          },
          child: Image.asset(
            'assets/logo.png',
            height: 40,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/mypage.jpg',
                height: 40,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('오류: $_errorMessage'))
              : ListView.builder(
                  itemCount: _diaries.length,
                  itemBuilder: (context, index) {
                    final diary = _diaries[index];
                    int _likeCount = diary['diary_liked'] ?? 0;

                    return InkWell(
                      onTap: () async {
                        await onDiaryTitleTap(diary['diary_id']);
                      },
                      child: Card(
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
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '글쓴이 : ${diary['user_id']}',
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          _formatDate(
                                              diary['diary_date'] ?? ''),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (diary['diary_image'] != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.network(
                                    diary['diary_image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  diary['diary_content'] ?? '내용 없음',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                              ),
                              const SizedBox(height: 8.0),

                              // 좋아요 및 댓글 버튼을 글 내용 아래에 배치
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.thumb_up,
                                            color:
                                                diary['liked_by_current_user']
                                                    ? Color.fromARGB(
                                                        255, 248, 104, 52)
                                                    : Color(0xFFFFAD8F),
                                          ),
                                          onPressed: () async {
                                            if (diary['diary_id'] != null) {
                                              await _toggleLike(
                                                  diary['diary_id'], index);
                                            }
                                          },
                                        ),
                                        Text('${diary['diary_liked'] ?? 0}'),
                                      ],
                                    ),
                                    const SizedBox(width: 16.0),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.comment,
                                            color: Color(0xFFFFAD8F),
                                          ),
                                          onPressed: () {
                                            _showCommentDialog(
                                                diary['diary_id'], index);
                                          },
                                        ),
                                        Text('${diary['comment_count'] ?? 0}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
