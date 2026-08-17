import 'package:flutter/material.dart';

import 'shop_page.dart';

/// Legacy entry kept for compatibility. COIN now opens the actual shop.
class CoinPage extends StatelessWidget {
  const CoinPage({super.key});

  @override
  Widget build(BuildContext context) => const ShopPage();
}
