import 'package:flutter/material.dart';

import '../services/coin_service.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  final CoinService coinService = CoinService();

  @override
  Widget build(BuildContext context) {
    final history = coinService.history.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('COIN 紀錄')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('目前餘額', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '🪙 ${coinService.balance}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('目前沒有交易紀錄'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];

                      return ListTile(
                        leading: Icon(
                          item.amount >= 0
                              ? Icons.add_circle
                              : Icons.remove_circle,
                          color: item.amount >= 0 ? Colors.green : Colors.red,
                        ),
                        title: Text(item.reason),
                        subtitle: Text(item.createdAt.toString()),
                        trailing: Text(
                          '${item.amount > 0 ? '+' : ''}${item.amount}',
                          style: TextStyle(
                            color: item.amount >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
