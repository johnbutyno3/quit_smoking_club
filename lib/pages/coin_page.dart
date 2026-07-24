import 'package:flutter/material.dart';

import '../models/coin_transaction.dart';
import '../repositories/coin/coin_repository.dart';
import '../services/coin_service.dart';
import '../usecases/coin/get_coin_balance_usecase.dart';
import '../l10n/app_localizations.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  final CoinRepository _coinRepository = CoinRepository(CoinService());
  final CoinService _coinService = CoinService();
  late final GetCoinBalanceUseCase _getCoinBalanceUseCase =
      GetCoinBalanceUseCase(_coinRepository);

  int _balance = 0;

  final List<CoinTransaction> _history = [];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _getCoinBalanceUseCase.execute();

    if (!mounted) return;

    setState(() {
      _balance = balance;
      _history
        ..clear()
        ..addAll(_coinService.history);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.coinHistory)),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.currentBalance,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🪙 $_balance',
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
            child: _history.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noTransactionHistory,
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];

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
