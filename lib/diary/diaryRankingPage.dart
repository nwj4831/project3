import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import

class DiaryRankingPage extends StatefulWidget {
  @override
  _DiaryRankingPageState createState() => _DiaryRankingPageState();
}

class _DiaryRankingPageState extends State<DiaryRankingPage> {
  final supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>>? _diaryRanking;

  @override
  void initState() {
    super.initState();
    _fetchDiaryRanking();
  }

  // Supabase에서 일기 데이터를 가져오고 댓글 수와 좋아요 수를 합산하는 함수
  Future<void> _fetchDiaryRanking() async {
    // 1. diary 테이블에서 diary_hit, diary_content, user_id, diary_date 값을 가져옴
    final List<dynamic> diaryResponse = await supabase
        .from('diary')
        .select('diary_id, diary_hit, diary_content, user_id, diary_date'); // user_id, diary_date 추가

    List<Map<String, dynamic>> rankingList = [];

    // 2. 각 diary에 대해 comment 테이블에서 댓글 수를 계산하고 liked 테이블에서 좋아요 수를 계산
    for (var diary in diaryResponse) {
      final diaryId = diary['diary_id'];
      final diaryContent = diary['diary_content']; // diary_content 가져오기
      final userId = diary['user_id']; // user_id 가져오기
      final diaryDate = diary['diary_date']; // diary_date 가져오기

      // 3. comment 테이블에서 해당 diary_id에 해당하는 댓글 수를 가져옴
      final List<dynamic> commentResponse = await supabase
          .from('comment')
          .select('comment_id')
          .eq('diary_id', diaryId);

      final commentCount = commentResponse.length; // 댓글 개수

      // 4. liked 테이블에서 해당 diary_id에 해당하는 좋아요 수를 가져옴
      final List<dynamic> likedResponse = await supabase
          .from('liked')
          .select('liked_id') // 좋아요의 id 값 가져오기
          .eq('diary_id', diaryId);

      final likedCount = likedResponse.length; // 좋아요 개수

      // 5. diary_hit + likedCount + commentCount를 더해서 total_score 계산
      final diaryHit = diary['diary_hit'] ?? 0;
      final totalScore = diaryHit + likedCount + commentCount;

      rankingList.add({
        'diary_id': diaryId,
        'diary_content': diaryContent,
        'user_id': userId,
        'diary_date': diaryDate,
        'total_score': totalScore,
      });
    }

    // 6. total_score에 따라 내림차순으로 정렬
    rankingList.sort((a, b) => b['total_score'].compareTo(a['total_score']));

    // 7. 상태 업데이트
    setState(() {
      _diaryRanking = Future.value(rankingList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인기 일기 순위'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _diaryRanking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('순위 데이터를 찾을 수 없습니다.'));
          } else {
            final rankingList = snapshot.data!;
            return ListView.builder(
              itemCount: rankingList.length,
              itemBuilder: (context, index) {
                final diary = rankingList[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text('Content: ${diary['diary_content']}'),
                      subtitle: Text('Total Score: ${diary['total_score']}, User ID: ${diary['user_id']}, Date: ${diary['diary_date']}'),
                    ),
                    const Divider(thickness: 1), // 밑줄 추가
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
