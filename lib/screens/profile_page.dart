import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../usecases/storage/storage_facade_usecase.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  int _age = 0;
  int _yearsSmoking = 0;
  bool _premium = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await StorageFacadeUseCase.getUserName();
    final age = await StorageFacadeUseCase.getUserAge();
    final years = await StorageFacadeUseCase.getUserYears();
    final premium = await StorageFacadeUseCase.getPremium();
    if (!mounted) return;
    setState(() {
      _name = name;
      _age = age;
      _yearsSmoking = years;
      _premium = premium;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 46, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _name.isEmpty ? t.anonymousUser : _name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Chip(
              avatar: const Icon(Icons.workspace_premium, size: 18),
              label: Text(_premium ? t.homePremiumMember : t.homeRegularMember),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(t.postName),
                  trailing: Text(_name.isEmpty ? '-' : _name),
                ),
                ListTile(
                  leading: const Icon(Icons.cake_outlined),
                  title: Text(t.hello),
                  trailing: Text(_age > 0 ? '$_age' : '-'),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(t.quitPlan),
                  trailing: Text(_yearsSmoking > 0 ? '$_yearsSmoking' : '-'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
