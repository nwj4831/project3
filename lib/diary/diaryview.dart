import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _likeCount = widget.diary['diary_liked'] ?? 0; // 초기 좋아요 수 설정
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final diaryId = widget.diary['diary_id'];
    try {
      final response = await supabase
          .from('comment')
          .select()
          .eq('diary_id', diaryId)
          .order('comment_date', ascending: false); // 최신 댓글이 상단에 오도록 정렬

      setState(() {
        _comments = response.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('댓글 가져오기 오류: $e');
    }
  }

  Future<void> _postComment(String commentContent) async {
    String? userId = await secureStorage.read(key: 'user_id');

    try {
      await supabase
          .from('comment')
          .insert({
            'diary_id': widget.diary['diary_id'],
            'user_id': userId,
            'comment_content': commentContent,
            'comment_date': DateTime.now().toIso8601String(),
          });
      await _fetchComments(); // 댓글 작성 후 댓글 목록 갱신
    } catch (e) {
      print('댓글 게시 오류: $e');
    }
  }

  Future<void> _updateLikeCount(int newLikeCount) async {
    try {
      print('Updating like count to $newLikeCount for diary ID: ${widget.diary['diary_id']}');
      await supabase
          .from('diary')
          .update({'diary_liked': newLikeCount})
          .eq('diary_id', widget.diary['diary_id']);
      setState(() {
        _likeCount = newLikeCount;
      });
    } catch (e) {
      print('좋아요 업데이트 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 보기'),
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
            Text(
              _formatDate(widget.diary['diary_date'] ?? ''),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: _likeCount % 2 != 0 ? Color.fromARGB(255, 248, 104, 52) : Color(0xFFFFAD8F),
                  ),
                  onPressed: () {
                    int newLikeCount = _likeCount % 2 == 0 ? _likeCount + 1 : _likeCount - 1;
                    _updateLikeCount(newLikeCount);
                  },
                ),
                Text('$_likeCount', style: const TextStyle(color: Color(0xFF333333))),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요...',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _postComment(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment['user_id'], style: TextStyle(fontWeight: FontWeight.bold)), // 작성자 ID
                        Text(comment['comment_content']), // 댓글 내용
                        Text(
                          _formatCommentDate(comment['comment_date']), // 작성 시간
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
