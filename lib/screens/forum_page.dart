import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

// 🎨 論壇專用美工色彩：引入社群媒體簡約色調
class _ForumColors {
  static const bg = Color(0xFFF5F7F6); // 高級極簡灰白背景
  static const cardBg = Colors.white; // 純白懸浮卡片
  static const heart = Color(0xFFFF5252); // 亮粉紅按讚
  static const gift = Color(0xFFFF9100); // 暖橘送禮
}

class _ForumPageState extends State<ForumPage> {
  int _myCoins = 0;

  // 模擬大綱 3.2.3 的論壇求救文數據流
  final List<Map<String, dynamic>> _posts = [
    {
      "name": "戒菸小幫手",
      "time": "10分鐘前",
      "content": "🚨 系統廣播：使用者剛剛按下了 SOS 求救按鈕！他目前正在緩解艙忍耐中，請大家留言幫他打氣加油！",
      "likes": 12,
      "gifts": 3,
      "isSOS": true,
    },
    {
      "name": "老菸槍阿明",
      "time": "1小時前",
      "content": "今天是我戒菸的第 7 天！排程表上的膠囊全部被我精準打勾變綠色，這種掌控自己時間的感覺真的太爽了！",
      "likes": 45,
      "gifts": 8,
      "isSOS": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadForumData();
  }

  Future<void> _loadForumData() async {
    final coins = await StorageService.getCoins();
    setState(() {
      _myCoins = coins;
    });
  }

  void _handleLike(int index) {
    setState(() {
      _posts[index]["likes"] = _posts[index]["likes"] + 1;
    });
  }

  Future<void> _handleSendGift(int index) async {
    // 💡 跨頁面商務閉環：檢查金幣是否足夠扣除
    if (_myCoins >= 5) {
      final latestCoins = _myCoins - 5;
      await StorageService.saveCoins(latestCoins);

      setState(() {
        _myCoins = latestCoins;
        _posts[index]["gifts"] = _posts[index]["gifts"] + 1;
      });
      _showSnack("🎁 成功花費 5 金幣送出冰鎮薄荷糖！");
    } else {
      _showSnack("❌ 金幣不足！請前往金幣商城儲值包！");
    }
  }

  void _showSnack(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ForumColors.bg,
      appBar: AppBar(
        title: const Text(
          "交流論壇",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 💡 1. 頂部透光磨砂錢包看板：與主頁面、商城完美呼應
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "我的剩餘金幣",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    "$_myCoins 💎",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 💡 2. 現代風社群卡片流 (Social Feed)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                final isSOS = post["isSOS"] as bool;

                return Card(
                  color: _ForumColors.cardBg,
                  elevation: isSOS ? 4 : 2,
                  shadowColor: isSOS
                      ? Colors.redAccent.withOpacity(0.2)
                      : Colors.black12,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSOS
                          ? Colors.redAccent.withOpacity(0.3)
                          : Colors.grey.shade100,
                      width: isSOS ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 發文者頭像與時間
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 36,
                              color: isSOS
                                  ? Colors.redAccent
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post["name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSOS
                                          ? Colors.redAccent
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    post["time"],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSOS)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "🚨 求助文",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 貼文內文
                        Text(
                          post["content"],
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.grey.shade800,
                            fontWeight: isSOS
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // 💡 3. 社群連動互動按鈕組
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // 按讚按鈕
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: _ForumColors.heart,
                              ),
                              icon: const Icon(Icons.favorite_border, size: 18),
                              label: Text(
                                "${post["likes"]} 讚",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => _handleLike(index),
                            ),
                            // 送禮按鈕
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: _ForumColors.gift,
                              ),
                              icon: const Icon(Icons.card_giftcard, size: 18),
                              label: Text(
                                "${post["gifts"]} 禮物",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => _handleSendGift(index),
                            ),
                          ],
                        ),
                      ],
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
