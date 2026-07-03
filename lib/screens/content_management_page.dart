import 'package:flutter/material.dart';
import '../services/content_service.dart';

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  final ContentService _service = ContentService();
  final List<String> _categories = [
    'Medical',
    'Stories',
    'YouTube',
    'Music',
    'Games',
  ];
  String _selectedCategory = 'Medical';
  late Future<List<ContentItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _service.getAllOverrideItems();
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = _service.getAllOverrideItems();
    });
  }

  void _openEditor([ContentItem? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ContentEditPage(category: _selectedCategory, initialItem: item),
      ),
    ).then((_) => _refreshItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('內容管理')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openEditor(null),
              child: const Text('新增內容'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<ContentItem>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('無內容資料'));
                  }
                  final items = snapshot.data!
                      .where((item) => item.category == _selectedCategory)
                      .toList();
                  if (items.isEmpty) {
                    return const Center(child: Text('目前無資料'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text('${item.language} • ${item.link}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openEditor(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _service.deleteOverrideItem(
                                  item.uniqueId,
                                );
                                _refreshItems();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentEditPage extends StatefulWidget {
  final String category;
  final ContentItem? initialItem;

  const ContentEditPage({super.key, required this.category, this.initialItem});

  @override
  State<ContentEditPage> createState() => _ContentEditPageState();
}

class _ContentEditPageState extends State<ContentEditPage> {
  final _languageCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final ContentService _service = ContentService();

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _languageCtrl.text = widget.initialItem!.language;
      _titleCtrl.text = widget.initialItem!.title;
      _contentCtrl.text = widget.initialItem!.content;
      _linkCtrl.text = widget.initialItem!.link;
    }
  }

  Future<void> _save() async {
    final item = ContentItem(
      category: widget.category,
      language: _languageCtrl.text.trim().toLowerCase(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
    );
    await _service.saveOverrideItem(item);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('編輯內容')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            Text('分類：${widget.category}'),
            const SizedBox(height: 12),
            TextField(
              controller: _languageCtrl,
              decoration: const InputDecoration(
                labelText: '語言代碼 (zh-tw / en / es / all)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: '標題'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: '內容'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkCtrl,
              decoration: const InputDecoration(labelText: '連結網址'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('儲存')),
          ],
        ),
      ),
    );
  }
}
