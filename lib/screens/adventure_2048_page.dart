import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adventure2048Page extends StatefulWidget {
  const Adventure2048Page({super.key});
  @override
  State<Adventure2048Page> createState() => _Adventure2048PageState();
}

class _Creature {
  final int value;
  final String name;
  final String emoji;
  const _Creature(this.value, this.name, this.emoji);
}

class _Chapter {
  final int id;
  final String name;
  final String theme;
  const _Chapter(this.id, this.name, this.theme);
}

class _Adventure2048PageState extends State<Adventure2048Page> {
  static const n = 4;
  static const chapters = <_Chapter>[
    _Chapter(1, '生命起源', '深海'),
    _Chapter(2, '生命登陸', '陸地'),
    _Chapter(3, '征服天空', '天空'),
    _Chapter(4, '文明誕生', '文明'),
    _Chapter(5, '走向星空', '太空'),
    _Chapter(6, '宇宙巨構', '宇宙'),
  ];
  static const creatures = <_Creature>[
    _Creature(2, '有機原湯', '🫧'),
    _Creature(4, '初級生命', '🧬'),
    _Creature(8, '複雜原始生命', '🦠'),
    _Creature(16, '主動型生命', '🌀'),
    _Creature(32, '遠古甲殼生命', '🦐'),
    _Creature(64, '奇蝦', '🦐'),
    _Creature(128, '古代魚類祖先', '🐟'),
    _Creature(256, '大型古代海洋生命', '🐠'),
    _Creature(512, '遠古海洋巨獸', '🐋'),
    _Creature(1024, '海洋霸主', '🐳'),
    _Creature(2048, '創世鯨', '🌊'),
  ];

  final _rng = Random();
  late List<List<int?>> board;
  List<List<int?>>? undo;
  int chapter = 1, score = 0, best = 0, coins = 20, moves = 0, combo = 0;
  bool won = false, over = false, loading = true;
  Offset? dragStart;

  bool get toolsEnabled => chapter < 6;
  _Chapter get current => chapters[chapter - 1];
  _Creature creature(int v) => creatures.firstWhere((x) => x.value == v, orElse: () => creatures.first);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    coins = p.getInt('adv2048_coins') ?? 20;
    chapter = (p.getInt('adv2048_chapter') ?? 1).clamp(1, 6);
    best = p.getInt('adv2048_best') ?? 0;
    _reset(false);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('adv2048_coins', coins);
    await p.setInt('adv2048_chapter', chapter);
    await p.setInt('adv2048_best', best);
  }

  void _reset([bool reward = true]) {
    board = List.generate(n, (_) => List<int?>.filled(n, null));
    score = 0; moves = 0; combo = 0; won = false; over = false; undo = null;
    _spawn(); _spawn();
    if (reward) coins += 1;
    _save();
    if (mounted) setState(() {});
  }

  void _spawn() {
    final empty = <Point<int>>[];
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) if (board[r][c] == null) empty.add(Point(r, c));
    }
    if (empty.isEmpty) return;
    final p = empty[_rng.nextInt(empty.length)];
    board[p.x][p.y] = _rng.nextDouble() < .9 ? 2 : 4;
  }

  bool _move(int dr, int dc) {
    if (over) return false;
    undo = [for (final row in board) [...row]];
    final before = [for (final row in board) [...row]];
    var merged = false;

    for (var line = 0; line < n; line++) {
      final values = <int>[];
      for (var step = 0; step < n; step++) {
        final r = dr != 0 ? (dr > 0 ? n - 1 - step : step) : line;
        final c = dc != 0 ? (dc > 0 ? n - 1 - step : step) : line;
        final v = board[r][c];
        if (v != null && v > 0) values.add(v);
      }
      final result = <int>[];
      for (var i = 0; i < values.length; i++) {
        if (i + 1 < values.length && values[i] == values[i + 1]) {
          final v = values[i] * 2;
          result.add(v); score += v; merged = true; i++;
        } else {
          result.add(values[i]);
        }
      }
      while (result.length < n) result.add(0);
      for (var step = 0; step < n; step++) {
        final r = dr != 0 ? (dr > 0 ? n - 1 - step : step) : line;
        final c = dc != 0 ? (dc > 0 ? n - 1 - step : step) : line;
        board[r][c] = result[step] == 0 ? null : result[step];
      }
    }

    if (_same(before, board)) { undo = null; return false; }
    moves++;
    combo = merged ? combo + 1 : 0;
    _spawn();
    if (merged) coins += min(combo, 3);
    _spawnObstacle();
    if (score > best) best = score;
    _checkWin();
    over = !_canMove();
    _save();
    setState(() {});
    return true;
  }

  bool _same(List<List<int?>> a, List<List<int?>> b) {
    for (var r = 0; r < n; r++) for (var c = 0; c < n; c++) if (a[r][c] != b[r][c]) return false;
    return true;
  }

  void _spawnObstacle() {
    if (chapter == 1 || moves == 0) return;
    final interval = chapter == 6 ? 7 : 10;
    if (moves % interval != 0) return;
    final empty = <Point<int>>[];
    for (var r = 0; r < n; r++) for (var c = 0; c < n; c++) if (board[r][c] == null) empty.add(Point(r, c));
    if (empty.isEmpty) return;
    final p = empty[_rng.nextInt(empty.length)];
    board[p.x][p.y] = -1;
  }

  bool _canMove() {
    for (var r = 0; r < n; r++) for (var c = 0; c < n; c++) {
      if (board[r][c] == null) return true;
      if (r + 1 < n && board[r][c] != -1 && board[r][c] == board[r + 1][c]) return true;
      if (c + 1 < n && board[r][c] != -1 && board[r][c] == board[r][c + 1]) return true;
    }
    return false;
  }

  void _checkWin() {
    if (won || !board.any((row) => row.contains(2048))) return;
    won = true;
    coins += chapter == 6 ? 50 : 20;
    if (chapter < 6) chapter++;
    _save();
  }

  Future<bool> _pay(int cost) async {
    if (!toolsEnabled || coins < cost) return false;
    coins -= cost; await _save(); return true;
  }

  Future<void> _clear() async {
    if (!toolsEnabled || !await _pay(15)) return;
    final rocks = <Point<int>>[];
    for (var r = 0; r < n; r++) for (var c = 0; c < n; c++) if (board[r][c] == -1) rocks.add(Point(r, c));
    if (rocks.isEmpty) { coins += 15; await _save(); _toast('目前沒有障礙物'); return; }
    final p = rocks[_rng.nextInt(rocks.length)]; board[p.x][p.y] = null; setState(() {});
  }

  Future<void> _shuffle() async {
    if (!toolsEnabled || !await _pay(25)) return;
    final vals = <int>[];
    for (final row in board) for (final v in row) if (v != null && v > 0) vals.add(v);
    vals.shuffle(_rng); var i = 0;
    for (var r = 0; r < n; r++) for (var c = 0; c < n; c++) if (board[r][c] != -1) board[r][c] = i < vals.length ? vals[i++] : null;
    setState(() {});
  }

  Future<void> _undoMove() async {
    if (undo == null) { _toast('沒有可回退的步驟'); return; }
    if (!toolsEnabled || !await _pay(35)) return;
    board = [for (final row in undo!) [...row]]; undo = null; over = false; setState(() {});
  }

  Future<void> _evolve() async {
    if (!toolsEnabled || !await _pay(60)) return;
    final cells = <Point<int>>[];
    for (var r = 0; r < n; r++) for (var c = 0; c < n; c++) {
      final v = board[r][c]; if (v != null && v >= 2 && v <= 64) cells.add(Point(r, c));
    }
    if (cells.isEmpty) { coins += 60; await _save(); _toast('沒有符合條件的生命體'); return; }
    final p = cells[_rng.nextInt(cells.length)]; board[p.x][p.y] = board[p.x][p.y]! * 2; setState(() {});
  }

  void _toast(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  void _panStart(DragStartDetails d) => dragStart = d.localPosition;
  void _panEnd(DragEndDetails d) {
    if (dragStart == null || d.velocity.pixelsPerSecond.distance < 120) return;
    final v = d.velocity.pixelsPerSecond;
    if (v.dx.abs() > v.dy.abs()) { _move(0, v.dx > 0 ? 1 : -1); }
    else { _move(v.dy > 0 ? 1 : -1, 0); }
  }

  Color _color(int v) => v == -1 ? const Color(0xFF546E7A) : <int, Color>{
    2: const Color(0xFFB2EBF2), 4: const Color(0xFF80CBC4), 8: const Color(0xFFA5D6A7), 16: const Color(0xFFDCE775),
    32: const Color(0xFFFFD54F), 64: const Color(0xFFFFB74D), 128: const Color(0xFFFF8A65), 256: const Color(0xFFEF5350),
    512: const Color(0xFFBA68C8), 1024: const Color(0xFF7E57C2), 2048: const Color(0xFF26A69A),
  }[v] ?? const Color(0xFF455A64);

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFF081C24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2731), foregroundColor: Colors.white,
        title: Text('冒險版 2048 · ${current.name}'),
        actions: [Padding(padding: const EdgeInsets.all(12), child: Center(child: Text('🪙 $coins')))],
      ),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 6), child: Row(children: [
          Expanded(child: Text('第 $chapter 章 · ${current.theme}\n目標：2048', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          _stat('分數', score), const SizedBox(width: 6), _stat('最高', best), if (combo >= 2) ...[const SizedBox(width: 6), _stat('COMBO', combo)],
        ])),
        Expanded(child: _board()),
        _tools(),
        Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Row(children: [
          Expanded(child: OutlinedButton(onPressed: _showChapters, child: const Text('章節進度'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: () => _reset(), child: const Text('重新開始'))),
        ])),
      ])),
    );
  }

  Widget _stat(String a, int b) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(9)), child: Column(children: [Text(a, style: const TextStyle(color: Colors.white54, fontSize: 8)), Text('$b', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]));

  Widget _board() => Center(child: AspectRatio(aspectRatio: 1, child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFF16424F), borderRadius: BorderRadius.circular(18)), child: GestureDetector(onPanStart: _panStart, onPanEnd: _panEnd, child: GridView.builder(physics: const NeverScrollableScrollPhysics(), itemCount: 16, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4), itemBuilder: (_, i) => _cell(board[i ~/ 4][i % 4]))))));

  Widget _cell(int? v) {
    if (v == null) return Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)));
    if (v == -1) return Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: _color(v), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('🪨', style: TextStyle(fontSize: 30))));
    final c = creature(v);
    return Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: _color(v), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: _color(v).withAlpha(70), blurRadius: 7)]), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.emoji, style: TextStyle(fontSize: v >= 1024 ? 24 : 32)), Text('$v', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black54))])));
  }

  Widget _tools() => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(children: [
    _tool('🔨', '清除', 15, _clear), _tool('🔄', '重排', 25, _shuffle), _tool('⏪', '回退', 35, _undoMove), _tool('🧬', '進化', 60, _evolve),
  ]));

  Widget _tool(String icon, String name, int cost, VoidCallback action) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: OutlinedButton(onPressed: toolsEnabled ? action : null, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 7)), child: Column(children: [Text(icon), Text(name, style: const TextStyle(fontSize: 10)), Text(toolsEnabled ? '$cost 🪙' : '第六章禁用', style: const TextStyle(fontSize: 8, color: Colors.white54))]))));

  void _showChapters() => showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF102B34), builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('冒險進度', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 10),
    for (final c in chapters) ListTile(dense: true, leading: Icon(c.id <= chapter ? Icons.check_circle : Icons.lock, color: c.id <= chapter ? Colors.tealAccent : Colors.white30), title: Text('第 ${c.id} 章 · ${c.name}', style: const TextStyle(color: Colors.white)), subtitle: Text(c.theme, style: const TextStyle(color: Colors.white54)), trailing: c.id == 6 ? const Text('無工具', style: TextStyle(color: Colors.orangeAccent, fontSize: 11)) : null),
  ]))));
}
