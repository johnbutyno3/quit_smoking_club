import 'package:flutter/material.dart';

import '../models/ranking_model.dart';
import '../repositories/ranking_repository.dart';
import '../usecases/ranking/get_rankings_usecase.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final GetRankingsUseCase _getRankings = GetRankingsUseCase(
    RankingRepository(),
  );

  List<RankingModel> _rankings = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _getRankings.execute();

    if (!mounted) return;

    setState(() {
      _rankings = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('全球排行榜')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _rankings.length,
              itemBuilder: (context, index) {
                final item = _rankings[index];

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item.nickname),
                  subtitle: Text('戒菸 ${item.quitDays} 天'),
                  trailing: Text(
                    '${item.totalScore}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}
