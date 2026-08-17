import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adventure 2048 prototype.
///
/// Art is intentionally represented by emoji placeholders. Creature assets can
/// later replace the `emoji` values without changing game logic.
class Adventure2048Page extends StatefulWidget {
  const Adventure2048Page({super.key});

  @override
  State<Adventure2048Page> createState() => _Adventure2048PageState();
}

class _CreatureDef {
  final int value;
  final String name;
  final String emoji;
  const _CreatureDef(this.value, this.name, this.emoji);
}

class _ChapterDef {
  final int id;
  final String name;
  final String theme;
  final int target;
  const _ChapterDef(this.id, this.name, this.theme, this.target);
}

class _Cell {
  int value;
  final int id;
  _Cell(this.value, this.id);
}

class _Adventure2048PageState extends State<Adventure2048Page> {
  static const int size = 4;
  static const int finalValue = 2048;
  static const String coinKey = 'adventure_2048_coins';
  static const String chapterKey = 'adventure_2048_chapter';
  static const String bestKey = 'adventure_2048_best';
  static const String completedKey = 'adventure_2048_completed';

  static const chapters = <_ChapterDef>[
    _ChapterDef(1, '生命起源', '深海', 2048),
    _ChapterDef(2, '生命登陸', '陸地', 2048),
    _ChapterDef(3, '征服天空', '天空', 2048),
    _ChapterDef(4, '文明誕生', '文明', 2048),
    _ChapterDef(5, '走向星空', '太空', 2048),
    _ChapterDef(6, '宇宙巨構', '宇宙', 2048),
  ];

  static const creatures = <_CreatureDef>[
    _CreatureDef(2, '有機原湯', '🫧'),
    _CreatureDef(4, '初級生命', '🧬'),
    _CreatureDef(8, '複雜原始生命', '🦠'),
    _CreatureDef(16, '主動型生命', '🌀'),
    _CreatureDef(32, '遠古甲殼生命', '🦐'),
    _CreatureDef(64, '奇蝦', '🦐'),
    _CreatureDef(128, '古代魚類祖先', '🐟'),
    _CreatureDef(256, '大型古代海洋生命', '🐠'),
    _CreatureDef(512, '遠古海洋巨獸', '🐋'),
    _CreatureDef(1024, '海洋霸主', '🐳'),
    _CreatureDef(2048, '創世鯨', '🌊'),
  ];

  List<List<_Cell?>> board = [];
  final Random _random = Random();
  int _nextId = 0;
  int score = 0;
  int best = 0;
  int coins = 0;
  int chapter = 1;
  int moves = 0;
  int combo = 0;
  int maxCombo = 0;
  int obstacleCount = 0;
  bool gameOver = false;
  bool won = false;
  bool _loading = true;
  Offset? _dragStart;

  int _toolClear = 0;
  int _toolShuffle = 0;
  int _toolUndo = 0;
  int _toolEvolve = 0;
  List<List<int?>>? _undoBoard;
  int _undoScore = 0;

  _ChapterDef get currentChapter => chapters[chapter - 1];
  bool get toolsEnabled => chapter < 6;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    coins = prefs.getInt(coinKey) ?? 20;
    chapter = (prefs.getInt(chapterKey) ?? 1).clamp(1, 6);
    best = prefs.getInt(bestKey) ?? 0;
    _newGame(addInitialReward: false);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(coinKey, coins);
    await prefs.setInt(chapterKey, chapter);
    await prefs.setInt(bestKey, best);
  }

  void _newGame({bool addInitialReward = false}) {
    board = List.generate(size, (_) => List<_Cell?>.filled(size, null));
    score = 0;
    moves = 0;
    combo = 0;
    maxCombo = 0;
    obstacleCount = 0;
    gameOver = false;
    won = false;
    _undoBoard = null;
    _toolClear = 0;
    _toolShuffle = 0;
    _toolUndo = 0;
    _toolEvolve = 0;
    _addRandom();
    _addRandom();
    if (addInitialReward) coins += 1;
    _saveProgress();
    if (mounted) setState(() {});
  }

  _Cell? _copyCell(_Cell? c) => c == null ? null : _Cell(c.value, c.id);

  void _saveUndo() {
    _undoBoard = [
      for (final row in board) [for (final c in row) c?.value],
    ];
    _undoScore = score;
  }

  void _restoreUndo() {
    if (_undoBoard == null) return;
    board = List.generate(
      size,
      (r) => List.generate(size, (c) {
        final value = _undoBoard![r][c];
        return value == null ? null : _Cell(value, _nextId++);
      }),
    );
    score = _undoScore;
    combo = 0;
    _undoBoard = null;
    gameOver = false;
    setState(() {});
  }

  void _addRandom() {
    final empty = <Point<int>>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == null) empty.add(Point(r, c));
      }
    }
    if (empty.isEmpty) return;
    final p = empty[_random.nextInt(empty.length)];
    board[p.x][p.y] = _Cell(_random.nextDouble() < .9 ? 2 : 4, _nextId++);
  }

  bool _move(String direction) {
    if (gameOver) return false;
    _saveUndo();
    final before = board.map((r) => r.map((c) => c?.value).toList()).toList();
    var merged = false;

    for (var index = 0; index < size; index++) {
      final line = <_Cell>[];
      for (var i = 0; i < size; i++) {
        final r = direction == 'up' || direction == 'down' ? i : index;
        final c = direction == 'left' || direction == 'right' ? i : index;
        final cell = board[r][c];
        if (cell != null) line.add(_copyCell(cell)!);
      }
      if (direction == 'right' || direction == 'down') line.reverse();

      final result = <_Cell>[];
      for (var i = 0; i < line.length; i++) {
        if (i + 1 < line.length && line[i].value == line[i + 1].value) {
          final value = line[i].value * 2;
          result.add(_Cell(value, _nextId++));
          score += value;
          merged = true;
          i++;
        } else {
          result.add(line[i]);
        }
      }
      while (result.length < size) result.add(_Cell(0, -1));
      if (direction == 'right' || direction == 'down') result.reverse();

      for (var i = 0; i < size; i++) {
        final r = direction == 'up' || direction == 'down' ? i : index;
        final c = direction == 'left' || direction == 'right' ? i : index;
        board[r][c] = result[i].value == 0 ? null : result[i];
      }
    }

    final after = board.map((r) => r.map((c) => c?.value).toList()).toList();
    if (_sameBoard(before, after)) {
      _undoBoard = null;
      return false;
    }

    moves++;
    combo = merged ? combo + 1 : 0;
    if (merged) maxCombo = max(maxCombo, combo);
    _addRandom();
    if (merged) {
      final reward = min(3, combo);
      coins += reward;
    }
    _spawnObstacleIfNeeded();
    if (score > best) best = score;
    _checkWin();
    gameOver = !_canMove();
    _saveProgress();
    setState(() {});
    return true;
  }

  bool _sameBoard(List<List<int?>> a, List<List<int?>> b) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (a[r][c] != b[r][c]) return false;
      }
    }
    return true;
  }

  void _spawnObstacleIfNeeded() {
    // Chapter 2+ introduces occasional obstacles. Chapter 6 is intentionally
    // harder, but still uses the same 4x4 board and no tool assistance.
    final interval = chapter == 1 ? 0 : chapter == 6 ? 7 : 9;
    if (interval == 0 || moves % interval != 0) return;
    final empty = <Point<int>>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == null) empty.add(Point(r, c));
      }
    }
    if (empty.isEmpty) return;
    final p = empty[_random.nextInt(empty.length)];
    board[p.x][p.y] = _Cell(-1, _nextId++);
    obstacleCount++;
  }

  bool _canMove() {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == null) return true;
        if (r + 1 < size && _mergeable(board[r][c], board[r + 1][c])) return true;
        if (c + 1 < size && _mergeable(board[r][c], board[r][c + 1])) return true;
      }
    }
    return false;
  }

  bool _mergeable(_Cell? a, _Cell? b) =>
      a != null && b != null && a.value > 0 && a.value == b.value;

  void _checkWin() {
    final hasTarget = board.any((row) => row.any((c) => c?.value == finalValue));
    if (hasTarget && !won) {
      won = true;
      coins += chapter == 6 ? 50 : 20;
      if (chapter < 6) {
        _unlockNextChapter();
      }
    }
  }

  void _unlockNextChapter() {
    if (chapter >= 6) return;
    chapter++;
    _saveProgress();
  }

  Future<bool> _spend(int amount) async {
    if (!toolsEnabled || coins < amount) return false;
    coins -= amount;
    await _saveProgress();
    return true;
  }

  Future<void> _useClear() async {
    if (_toolClear == 0 && !await _spend(15)) return;
    final cells = <Point<int>>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c]?.value == -1) cells.add(Point(r, c));
      }
    }
    if (cells.isEmpty) return _snack('沒有可清除的障礙');
    final p = cells[_random.nextInt(cells.length)];
    board[p.x][p.y] = null;
    if (_toolClear > 0) _toolClear--;
    setState(() {});
  }

  Future<void> _useShuffle() async {
    if (_toolShuffle == 0 && !await _spend(25)) return;
    final cells = <_Cell>[];
    for (final row in board) {
      for (final c in row) {
        if (c != null && c.value > 0) cells.add(c);
      }
    }
    cells.shuffle(_random);
    var i = 0;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c]?.value == -1) continue;
        board[r][c] = i < cells.length ? cells[i++] : null;
      }
    }
    if (_toolShuffle > 0) _toolShuffle--;
    setState(() {});
  }

  Future<void> _useUndo() async {
    if (_undoBoard == null) return _snack('目前沒有可回退的步驟');
    if (_toolUndo == 0 && !await _spend(35)) return;
    if (_toolUndo > 0) _toolUndo--;
    _restoreUndo();
  }

  Future<void> _useEvolve() async {
    if (!await _spend(60)) return;
    final candidates = <Point<int>>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final value = board[r][c]?.value ?? 0;
        if (value >= 2 && value <= 64) candidates.add(Point(r, c));
      }
    }
    if (candidates.isEmpty) return _snack('沒有符合條件的生命體');
    final p = candidates[_random.nextInt(candidates.length)];
    board[p.x][p.y]!.value *= 2;
    setState(() {});
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _onPanStart(DragStartDetails d) => _dragStart = d.localPosition;

  void _onPanEnd(DragEndDetails d) {
    final start = _dragStart;
    if (start == null) return;
    final velocity = d.velocity.pixelsPerSecond;
    if (velocity.distance < 120) return;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      _move(velocity.dx > 0 ? 'right' : 'left');
    } else {
      _move(velocity.dy > 0 ? 'down' : 'up');
    }
  }

  _CreatureDef _creature(int value) =>
      creatures.firstWhere((c) => c.value == value, orElse: () => creatures.first);

  Color _tileColor(int value) {
    if (value == -1) return const Color(0xFF546E7A);
    final colors = <int, Color>{
      2: const Color(0xFFB2EBF2),
      4: const Color(0xFF80CBC4),
      8: const Color(0xFFA5D6A7),
      16: const Color(0xFFDCE775),
      32: const Color(0xFFFFD54F),
      64: const Color(0xFFFFB74D),
      128: const Color(0xFFFF8A65),
      256: const Color(0xFFEF5350),
      512: const Color(0xFFBA68C8),
      1024: const Color(0xFF7E57C2),
      2048: const Color(0xFF26A69A),
    };
    return colors[value] ?? const Color(0xFF455A64);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFF081C24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2731),
        foregroundColor: Colors.white,
        title: Text('冒險版 2048 · ${currentChapter.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('🪙 $coins', style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBoardArea()),
            _buildTools(),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${currentChapter.theme} · 第 $chapter 章', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('目標：${currentChapter.target}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          _stat('SCORE', score),
          const SizedBox(width: 8),
          _stat('BEST', best),
          if (combo >= 2) ...[
            const SizedBox(width: 8),
            _stat('COMBO', combo),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8)),
        Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _buildBoardArea() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF16424F),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanEnd: _onPanEnd,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 16,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (_, index) {
                final r = index ~/ 4;
                final c = index % 4;
                return _buildCell(board[r][c]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(_Cell? cell) {
    if (cell == null) {
      return Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)));
    }
    if (cell.value == -1) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: _tileColor(-1), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('🪨', style: TextStyle(fontSize: 34))),
      );
    }
    final creature = _creature(cell.value);
    final fontSize = cell.value >= 1024 ? 25.0 : cell.value >= 128 ? 29.0 : 34.0;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _tileColor(cell.value),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: _tileColor(cell.value).withAlpha(90), blurRadius: 7)],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(creature.emoji, style: TextStyle(fontSize: fontSize)),
            const SizedBox(height: 2),
            Text('${cell.value}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildTools() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _tool('🔨', '清除', 15, _useClear),
          _tool('🔄', '重排', 25, _useShuffle),
          _tool('⏪', '回退', 35, _useUndo),
          _tool('🧬', '進化', 60, _useEvolve),
        ],
      ),
    );
  }

  Widget _tool(String icon, String name, int price, VoidCallback onTap) {
    final enabled = toolsEnabled;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: enabled ? onTap : null,
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: enabled ? Colors.white24 : Colors.white10), padding: const EdgeInsets.symmetric(vertical: 8)),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            Text(name, style: const TextStyle(fontSize: 11)),
            Text(enabled ? '$price 🪙' : '第六章禁用', style: const TextStyle(fontSize: 8, color: Colors.white54)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showProgress(),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('章節'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _newGame(addInitialReward: true),
              icon: const Icon(Icons.refresh),
              label: const Text('重新開始'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgress() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF102B34),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('冒險進度', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              for (final c in chapters)
                ListTile(
                  dense: true,
                  leading: Icon(c.id <= chapter ? Icons.check_circle : Icons.lock, color: c.id <= chapter ? Colors.tealAccent : Colors.white30),
                  title: Text('第 ${c.id} 章 · ${c.name}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(c.theme, style: const TextStyle(color: Colors.white54)),
                  trailing: c.id == 6 ? const Text('無工具', style: TextStyle(color: Colors.orangeAccent, fontSize: 11)) : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
