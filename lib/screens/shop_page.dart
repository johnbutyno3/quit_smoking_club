import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../repositories/coin/coin_repository.dart';
import '../usecases/coin/add_coin_usecase.dart';
import '../usecases/coin/get_coin_balance_usecase.dart';
import '../usecases/coin/spend_coin_usecase.dart';
import '../usecases/storage/storage_facade_usecase.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class ShopColors {
  static const Color walletBackground = Color(0xFFFFF8E1);
  static const Color primaryGold = Color(0xFFFFC107);
  static const Color vipBackgroundStart = Color(0xFF1A1A1A);
  static const Color vipBackgroundEnd = Color(0xFF424242);
  static const Color vipGold = Color(0xFFFFD700);
}

class _ShopPageState extends State<ShopPage> {
  late final CoinRepository _coinRepository;
  late final GetCoinBalanceUseCase _getCoinBalanceUseCase;
  late final AddCoinUseCase _addCoinUseCase;
  late final SpendCoinUseCase _spendCoinUseCase;

  int _myCoins = 0;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _coinRepository = CoinRepository();
    _getCoinBalanceUseCase = GetCoinBalanceUseCase(_coinRepository);
    _addCoinUseCase = AddCoinUseCase(repository: _coinRepository);
    _spendCoinUseCase = SpendCoinUseCase(_coinRepository);
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final coins = await _getCoinBalanceUseCase.execute();
    final premium = await StorageFacadeUseCase.getPremium();

    if (!mounted) return;

    setState(() {
      _myCoins = coins;
      _isPremiumUser = premium;
    });
  }

  Future<void> buyCoins(int amount) async {
    await _addCoinUseCase.execute(amount, 'purchase_coin');
    final latest = await _getCoinBalanceUseCase.execute();

    if (!mounted) return;

    setState(() {
      _myCoins = latest;
    });

    _showMsg(AppLocalizations.of(context)!.purchaseSuccess);
  }

  Future<void> _unlockPremium() async {
    await StorageFacadeUseCase.savePremium(true);

    if (!mounted) return;

    setState(() {
      _isPremiumUser = true;
    });

    _showMsg(AppLocalizations.of(context)!.premiumActivated);
  }

  Future<void> _createForum() async {
    final success = await _spendCoinUseCase.execute(30, 'forum_create_post');

    if (!success) {
      if (!mounted) return;
      _showMsg(AppLocalizations.of(context)!.insufficientCoins);
      return;
    }

    final latest = await _getCoinBalanceUseCase.execute();
    if (!mounted) return;

    setState(() {
      _myCoins = latest;
    });

    _showMsg(AppLocalizations.of(context)!.postCreated);
  }

  void _showMsg(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.shop)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: ShopColors.walletBackground,
            child: ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: ShopColors.primaryGold,
              ),
              title: Text(t.myCoins),
              trailing: Text(
                '$_myCoins 🪙',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => buyCoins(10),
            child: Text(t.shopBuyCoins(10)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _createForum,
            child: Text(t.shopCreateForumPost),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.black87,
            child: ListTile(
              leading: const Icon(
                Icons.workspace_premium,
                color: ShopColors.vipGold,
              ),
              title: Text(
                _isPremiumUser ? t.shopVipActive : t.shopPremium,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: _isPremiumUser
                  ? const Text(
                      '✓',
                      style: TextStyle(
                        color: ShopColors.vipGold,
                        fontSize: 24,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _unlockPremium,
                      child: Text(t.shopVip),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
