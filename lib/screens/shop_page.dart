import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  // 3.2.4 模擬商城商品清單 (買越多越便宜)
  final List<Map<String, String>> _items = const [
    {"title": "Remove Ads", "price": "\$1.99"},
    {"title": "1 Coin Pack", "price": "\$0.99"},
    {"title": "5 Coins Pack (Save 10%)", "price": "\$3.99"},
    {"title": "10 Coins Pack (Save 20%)", "price": "\$6.99"},
    {"title": "100 Coins Pack (Best Value!)", "price": "\$49.99"},
    {"title": "Premium Membership (Monthly)", "price": "\$4.99"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.amber),
              title: Text(
                item["title"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Buying: ${item["title"]}")),
                  );
                },
                child: Text(item["price"] ?? ""),
              ),
            ),
          );
        },
      ),
    );
  }
}
