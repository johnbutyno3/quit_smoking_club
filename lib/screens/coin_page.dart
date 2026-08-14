import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/coin_transaction.dart';
import '../repositories/coin/coin_repository.dart';
import '../usecases/coin/get_coin_balance_usecase.dart';
import 'shop_page.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  final CoinRepository _coinRepository = CoinRepository();

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
    final history = await _coinRepository.getHistory();

    if (!mounted) return;

    setState(() {
      _balance = balance;
      _history
        ..clear()
        ..addAll(history);
    });
  }

  Future<void> _openShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ShopPage(),
      ),
    );

    if (!mounted) return;
    await _loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coinHistory)),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    l10n.currentBalance,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openShop,
                icon: const Icon(Icons.store),
                label: Text(l10n.shop),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Text(l10n.noTransactionHistory),
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
