import 'package:flutter/material.dart';
import 'package:project3/diary/diarylist.dart';
import 'package:project3/main.dart';
import 'package:project3/mypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class DiaryViewPage extends StatefulWidget {
  final Map<String, dynamic> diary;

  const DiaryViewPage({super.key, required this.diary});

  @override
  _DiaryViewPageState createState() => _DiaryViewPageState();
}

class _DiaryViewPageState extends State<DiaryViewPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _comments = [];
  int _likeCount = 0; // 좋아요 수
  bool _likedByUser = false; // 사용자가 좋아요를 눌렀는지 여부
  TextEditingController _commentController = TextEditingController(); // 댓글 입력 컨트롤러
  String? _currentUserId; // 현재 사용자 ID

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId(); // 현재 사용자 ID 가져오기
    _fetchLikeCount(); // 좋아요 수와 사용자의 좋아요 여부 불러오기
    _fetchComments();
  }

  Future<void> _fetchCurrentUserId() async {
    _currentUserId = await secureStorage.read(key: 'user_id');
    setState(() {}); // 상태 업데이트
  }

  Future<void> _fetchLikeCount() async {
    final diaryId = widget.diary['diary_id'];

    try {
      final response = await supabase
          .from('liked')
          .select('diary_id')
          .eq('diary_id', diaryId);

      bool likedByUser = false;
      if (_currentUserId != null) {
        final userLikeResponse = await supabase
            .from('liked')
            .select()
            .eq('diary_id', diaryId)
            .eq('user_id', _currentUserId!);

        likedByUser = userLikeResponse.isNotEmpty;
      }

      setState(() {
        _likeCount = response.length; // 전체 좋아요 수
        _likedByUser = likedByUser; // 사용자가 좋아요를 눌렀는지 여부
      });
    } catch (e) {
      print('좋아요 수 불러오기 오류: $e');
    }
  }

  Future<void> _fetchComments() async {
    final diaryId = widget.diary['diary_id'];
    try {
      final response = await supabase
          .from('comment')
          .select()
          .eq('diary_id', diaryId)
          .order('comment_date', ascending: false);

      setState(() {
        _comments = response.cast<Map<String, dynamic>>(); // 댓글 목록 가져오기
      });
    } catch (e) {
      print('댓글 가져오기 오류: $e');
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty || _currentUserId == null) {
      print('댓글 내용 또는 유저 ID가 비어있습니다.');
      return;
    }

    try {
      await supabase.from('comment').insert({
        'diary_id': widget.diary['diary_id'],
        'user_id': _currentUserId,
        'comment_content': _commentController.text,
        'comment_date': DateTime.now().toIso8601String(),
      });
      _commentController.clear(); // 댓글 입력 후 입력 칸 비우기
      await _fetchComments(); // 댓글 목록 갱신
      await _incrementUserMile(widget.diary['user_id']); 
    } catch (e) {
      print('댓글 게시 오류: $e');
    }
  }

    // user_mile 증가 함수
  Future<void> _incrementUserMile(String diaryUserId) async {
    String? currentUserId = await secureStorage.read(key: 'user_id');
    
    // 게시물의 user_id와 현재 댓글 작성자의 user_id가 다를 때만 실행
    if (currentUserId != null && currentUserId != diaryUserId) {
      try {
        // 현재 user_mile 조회
        final response = await supabase
            .from('users')
            .select('user_mile')
            .eq('user_id', diaryUserId)
            .single();

        // user_mile 값 증가
        int currentMile = response['user_mile'] as int;
        await supabase.from('users').update({
          'user_mile': currentMile + 10 // user_mile을 10 증가시킵니다.
        }).eq('user_id', diaryUserId); // 특정 user_id로 필터링

        print('user_mile이 10 증가했습니다.');
      } catch (e) {
        print('user_mile 증가 오류: $e');
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await supabase
          .from('comment')
          .delete()
          .eq('comment_id', commentId); // 댓글 삭제
      await _fetchComments(); // 댓글 목록 갱신
    } catch (e) {
      print('댓글 삭제 오류: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      print('User is not logged in. Cannot like or unlike.');
      return;
    }

    final diaryId = widget.diary['diary_id'];
    try {
      final response = await supabase
          .from('liked')
          .select()
          .eq('diary_id', diaryId)
          .eq('user_id', _currentUserId!);

      if (response.isEmpty) {
        await supabase.from('liked').insert({
          'diary_id': diaryId,
          'user_id': _currentUserId,
        });
        setState(() {
          _likeCount += 1;
          _likedByUser = true;
        });
      } else {
        await supabase
            .from('liked')
            .delete()
            .eq('diary_id', diaryId)
            .eq('user_id', _currentUserId!);
        setState(() {
          _likeCount -= 1;
          _likedByUser = false;
        });
      }
    } catch (e) {
      print('좋아요 업데이트 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DiaryListPage()), // DiaryListPage로 이동
            );
          },
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Main()), // Main으로 이동
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
                MaterialPageRoute(builder: (context) => MyPage()), // MyPage로 이동
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.diary['diary_content'] ?? '내용 없음',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(widget.diary['diary_date'] ?? ''),
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: _likedByUser
                            ? Color.fromARGB(255, 248, 104, 52)
                            : Color(0xFFFFAD8F),
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$_likeCount',
                        style: const TextStyle(color: Color(0xFF333333))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: '댓글을 입력하세요...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _postComment,
                  child: Text('게시'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝으로 정렬
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('작성자: ${comment['user_id']}',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(comment['comment_content']),
                              Text(
                                _formatDate(comment['comment_date']),
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // 현재 사용자 ID와 댓글 작성자 ID 비교
                        if (comment['user_id'] == _currentUserId)
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red), // X 아이콘
                            onPressed: () => _deleteComment(comment['comment_id'].toString()), // int를 String으로 변환
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
