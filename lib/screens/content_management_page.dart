import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/content/content_category.dart';
import '../models/content/content_item.dart';
import '../repositories/content/content_repository.dart';
import '../usecases/content/get_content_list_usecase.dart';

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  late final ContentRepository _repository;

  late final GetContentListUseCase _getContentListUseCase;

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

    _repository = ContentRepository();

    _getContentListUseCase = GetContentListUseCase(repository: _repository);

    _itemsFuture = _getContentListUseCase.execute(category: _selectedCategory);
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = _getContentListUseCase.execute(
        category: _selectedCategory,
      );
    });
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

  void _openEditor([ContentItem? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentEditPage(
          category: _selectedCategory,
          initialItem: item,
          repository: _repository,
        ),
      ),
    ).then((_) => _refreshItems());
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
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedCategory = value;

                  _itemsFuture = _getContentListUseCase.execute(
                    category: value,
                  );
                });
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => _openEditor(),

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
                      .where((e) => e.category == _selectedCategory)
                      .toList();

                  if (items.isEmpty) {
                    return Center(child: Text(l10n.contentManagementEmpty));
                  }

                  return ListView.builder(
                    itemCount: items.length,

                    itemBuilder: (context, index) {
                      final item = items[index];

                      return ListTile(
                        title: Text(item.title),

                        subtitle: Text(item.language),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete),

                          onPressed: () async {
                            await _repository.deleteContent(item.uniqueId);

                            _refreshItems();
                          },
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
  final _titleCtrl = TextEditingController();

  final _contentCtrl = TextEditingController();

  final _languageCtrl = TextEditingController();

  final _linkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    final item = widget.initialItem;

    if (item != null) {
      _titleCtrl.text = item.title;

      _contentCtrl.text = item.content;

      _languageCtrl.text = item.language;

      _linkCtrl.text = item.link;
    }
  }

  Future<void> _save() async {
    final item = ContentItem(
      id: widget.initialItem?.id ?? '',

      category: widget.category,

      language: _languageCtrl.text,

      title: _titleCtrl.text,

      content: _contentCtrl.text,

      link: _linkCtrl.text,
    );

    await widget.repository.saveContent(item);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contentManagementEditTitle)),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,

              decoration: InputDecoration(
                labelText: l10n.contentManagementTitleLabel,
              ),
            ),

            TextField(
              controller: _contentCtrl,

              maxLines: 5,

              decoration: InputDecoration(
                labelText: l10n.contentManagementContentLabel,
              ),
            ),

            TextField(
              controller: _linkCtrl,

              decoration: InputDecoration(
                labelText: l10n.contentManagementLinkLabel,
              ),
            ),

            ElevatedButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
