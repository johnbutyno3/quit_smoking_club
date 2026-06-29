import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _myCoins = 0;
  bool _isPremiumUser = false; // 紀錄是否開通高級會員

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final coins = await StorageService.getCoins();
    final premium = await StorageService.getPremium();
    setState(() {
      _myCoins = coins;
      _isPremiumUser = premium;
    });
  }

  Future<void> _buyCoins(int amount) async {
    final current = await StorageService.getCoins();
    final latest = current + amount;
    await StorageService.saveCoins(latest);
    setState(() {
      _myCoins = latest;
    });
  }

  Future<void> _unlockPremium() async {
    await StorageService.savePremium(true);
    setState(() {
      _isPremiumUser = true;
    });
    _showMsg("🎉 成功開通高級會員！免廣告權益已生效。");
  }

  Future<void> _createForum() async {
    if (_myCoins >= 50) {
      final latest = _myCoins - 50;
      await StorageService.saveCoins(latest);
      setState(() {
        _myCoins = latest;
      });
      _showMsg("成功扣除 50 金幣，送交管理員審核！");
    } else {
      _showMsg("❌ 金幣不足！請購買金幣包！");
    }
  }

  void _showMsg(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store & Forum")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 錢包看板
          Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: const Icon(Icons.wallet, color: Colors.orange),
              title: const Text("我的錢包"),
              trailing: Text(
                "$_myCoins 💎",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3.2.3 創建論壇按鈕
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            icon: const Icon(Icons.add_box),
            label: const Text("測試：創建新論壇 (扣50)"),
            onPressed: _createForum,
          ),
          const Divider(),

          // 3.2.4 階梯式金幣商品清單 (免廣告已移至高級會員內)
          _buildItem("購買 1 個金幣", 0.99, 1),
          _buildItem("購買 5 個金幣 (省10%)", 3.99, 5),
          _buildItem("購買 10 個金幣 (省20%)", 6.99, 10),
          _buildItem("購買 100 個金幣 (最划算)", 49.99, 100),

          // 高級會員專區
          Card(
            child: ListTile(
              leading: const Icon(Icons.card_membership, color: Colors.purple),
              title: const Text(
                "高級會員 (按月)",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "享專屬免廣告 + 跨天送100金幣",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              trailing: _isPremiumUser
                  ? const Text(
                      "已開通 🎉",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _unlockPremium,
                      child: const Text("\$4.99"),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, double price, int coinAmt) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_bag, color: Colors.amber),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _buyCoins(coinAmt);
            _showMsg("已成功充值 $coinAmt 金幣！");
          },
          child: Text("\$$price"),
        ),
      ),
    );
  }
}
