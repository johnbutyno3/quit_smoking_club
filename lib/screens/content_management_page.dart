import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../repositories/content/content_repository.dart';

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  final ContentRepository _repository = ContentRepository();
  final List<ContentCategory> _categories = const [
    ContentCategory.medical,
    ContentCategory.stories,
    ContentCategory.youtube,
    ContentCategory.music,
    ContentCategory.games,
  ];
  ContentCategory _selectedCategory = ContentCategory.medical;
  late Future<List<ContentItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _repository.getContents(category: _selectedCategory);
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = _repository.getContents(category: _selectedCategory);
    });
  }

  void _openEditor([ContentItem? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentEditPage(
          category: _selectedCategory,
          initialItem: item,
          repository: _repository,
        ),
      ),
    ).then((_) => _refreshItems());
  }

  String _categoryLabel(ContentCategory category) {
    switch (category) {
      case ContentCategory.medical:
        return 'Medical';
      case ContentCategory.stories:
        return 'Stories';
      case ContentCategory.youtube:
        return 'YouTube';
      case ContentCategory.music:
        return 'Music';
      case ContentCategory.games:
        return 'Games';
      case ContentCategory.reading:
        return 'Reading';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contentManagementTitle)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButton<ContentCategory>(
              value: _selectedCategory,
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(_categoryLabel(category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _itemsFuture = _repository.getContents(
                      category: _selectedCategory,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openEditor(null),
              child: Text(l10n.contentManagementAdd),
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
                    return Center(child: Text(l10n.contentManagementNoData));
                  }
                  final items = snapshot.data!
                      .where((item) => item.category == _selectedCategory)
                      .toList();
                  if (items.isEmpty) {
                    return Center(child: Text(l10n.contentManagementEmpty));
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
                                await _repository.deleteContent(item.uniqueId);
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
  final ContentCategory category;
  final ContentItem? initialItem;
  final ContentRepository repository;

  const ContentEditPage({
    super.key,
    required this.category,
    required this.repository,
    this.initialItem,
  });

  @override
  State<ContentEditPage> createState() => _ContentEditPageState();
}

class _ContentEditPageState extends State<ContentEditPage> {
  final _languageCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

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
      id: widget.initialItem?.id ?? '',
      category: widget.category,
      language: _languageCtrl.text.trim().toLowerCase(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
    );
    await widget.repository.saveContent(item);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contentManagementEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            Text(l10n.contentManagementCategory(widget.category.name)),
            const SizedBox(height: 12),
            TextField(
              controller: _languageCtrl,
              decoration: InputDecoration(
                labelText: l10n.contentManagementLanguageCode,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.contentManagementTitleLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.contentManagementContentLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkCtrl,
              decoration: InputDecoration(
                labelText: l10n.contentManagementLinkLabel,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
