import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

// 🎨 商城奢華美工色彩：引入 VIP 黑金與寶箱亮橘
class _ShopColors {
  static const walletBg = Color(0xFFFFF3E0); // 暖橘錢包背景
  static const goldText = Color(0xFFFFB300); // 金幣亮橘
  static const vipBgStart = Color(0xFF212121); // VIP卡黑金深色
  static const vipBgEnd = Color(0xFF424242); // VIP卡黑金淺色
  static const vipGold = Color(0xFFFFD700); // VIP尊榮純金
}

class _ShopPageState extends State<ShopPage> {
  int _myCoins = 0;
  bool _isPremiumUser = false;

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
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text(
          "代幣商城",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 💡 1. 磨砂反光橘色錢包看板
          Card(
            color: _ShopColors.walletBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.orange, width: 1),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: Colors.orange,
                size: 28,
              ),
              title: const Text(
                "我的虛擬錢包",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              trailing: Text(
                "$_myCoins 💎",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_to_photos),
            label: const Text(
              "模擬大綱 3.2.3：創建新論壇 (扣50)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _createForum,
          ),
          const Divider(height: 32),

          const Text(
            "💎 階梯式金幣儲值包 (3.2.4)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // 💡 2. 階梯寶箱商品卡片流
          _buildItem("精巧金幣袋 ( 1 顆金幣)", 0.99, 1, Icons.monetization_on),
          _buildItem("超值金幣盒 ( 5 顆金幣 - 省10%)", 3.99, 5, Icons.card_giftcard),
          _buildItem("豐盛金幣箱 ( 10 顆金幣 - 省20%)", 6.99, 10, Icons.inventory_2),
          _buildItem("至尊大寶箱 (100 顆金幣 - 最划算)", 49.99, 100, Icons.diamond),
          const SizedBox(height: 20),

          const Text(
            "👑 高級會員專區 (整合免廣告)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // 💡 3. 奢華黑金雙色漸層高級會員 VIP 卡片面
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_ShopColors.vipBgStart, _ShopColors.vipBgEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: _ShopColors.vipGold.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.workspace_premium,
                            color: _ShopColors.vipGold,
                            size: 24,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "PREMIUM MEMBER",
                            style: TextStyle(
                              color: _ShopColors.vipGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "• 享有專屬全App永久免廣告服務",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const Text(
                        "• 跨天 00:00 自動補發 100 顆金幣",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _isPremiumUser
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _ShopColors.vipGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _ShopColors.vipGold),
                        ),
                        child: const Text(
                          "已開通 🎉",
                          style: TextStyle(
                            color: _ShopColors.vipGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ShopColors.vipGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _unlockPremium,
                        child: const Text(
                          "\$4.99",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildItem(String title, double price, int coinAmt, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange.shade400, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _ShopColors.goldText,
            side: const BorderSide(color: Colors.orange),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            _buyCoins(coinAmt);
            _showMsg("已成功充值 $coinAmt 金幣！");
          },
          child: Text(
            "\$$price",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
