import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});
  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  // 3.2.3 模擬論壇資料庫列表
  final List<Map<String, String>> _forums = [
    {"id": "1", "title": "🚨 Smoking Craving (Fixed)"},
    {"id": "2", "title": "💪 90 Days Challenge Club"},
    {"id": "3", "title": "🍏 Health and Diet Chat"},
  ];

  // 3.2.3.2 創建論壇方法（大綱：需扣金幣與審核）
  void _createNewForum() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Forum"),
        content: const Text("Cost: 50 Coins.\nNeed Admin Review."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Submitted for review!")),
              );
            },
            child: const Text("Pay & Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forums")),
      body: Column(
        children: [
          // 3.2.3 頂部創建論壇選項
          ListTile(
            leading: const Icon(Icons.add_box, color: Colors.blue),
            title: const Text(
              "Create New Forum",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Requires coins & approval"),
            onTap: _createNewForum,
          ),
          const Divider(),
          // 論壇總表列表
          Expanded(
            child: ListView.builder(
              itemCount: _forums.length,
              itemBuilder: (context, index) {
                final forum = _forums[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.forum, color: Colors.green),
                    title: Text(forum["title"] ?? ""),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Entering: ${forum["title"]}")),
                      );
                    },
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
