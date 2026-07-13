import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════
//  交通工具 2048 — 完全內建，零 Firebase，零網路請求
//  等級：腳踏車 → 機車 → 汽車 → 貨車 → 大卡車
//        → 遊覽車 → 戰車 → 滑翔機 → 直升機 → 老飛機
//        → 戰機 → 空中巴士 → 航空母艦 → 太空飛船
// ══════════════════════════════════════════════════════════

// 等級對照（value 1=腳踏車 … 14=太空飛船，value 用 2^n 表示）
const _kLevels = [
  _Level(
    value: 2,
    emoji: '🚲',
    name: '腳踏車',
    bg: Color(0xFFD4E8C2),
    fg: Color(0xFF3A5A1C),
  ),
  _Level(
    value: 4,
    emoji: '🛵',
    name: '機車',
    bg: Color(0xFFC8E6C9),
    fg: Color(0xFF2E7D32),
  ),
  _Level(
    value: 8,
    emoji: '🚗',
    name: '汽車',
    bg: Color(0xFFFFE082),
    fg: Color(0xFF5D4037),
  ),
  _Level(
    value: 16,
    emoji: '🚚',
    name: '貨車',
    bg: Color(0xFFFFCC80),
    fg: Color(0xFF4E342E),
  ),
  _Level(
    value: 32,
    emoji: '🚛',
    name: '大卡車',
    bg: Color(0xFFFFAB91),
    fg: Color(0xFF4E342E),
  ),
  _Level(
    value: 64,
    emoji: '🚌',
    name: '遊覽車',
    bg: Color(0xFFEF9A9A),
    fg: Color(0xFFFFFFFF),
  ),
  _Level(
    value: 128,
    emoji: '🪖',
    name: '戰車',
    bg: Color(0xFF80CBC4),
    fg: Color(0xFF004D40),
  ),
  _Level(
    value: 256,
    emoji: '🪂',
    name: '滑翔機',
    bg: Color(0xFF80DEEA),
    fg: Color(0xFF006064),
  ),
  _Level(
    value: 512,
    emoji: '🚁',
    name: '直升機',
    bg: Color(0xFF81D4FA),
    fg: Color(0xFF01579B),
  ),
  _Level(
    value: 1024,
    emoji: '✈️',
    name: '老飛機',
    bg: Color(0xFF90CAF9),
    fg: Color(0xFF0D47A1),
  ),
  _Level(
    value: 2048,
    emoji: '🛩️',
    name: '戰機',
    bg: Color(0xFFCE93D8),
    fg: Color(0xFF4A148C),
  ),
  _Level(
    value: 4096,
    emoji: '🛫',
    name: '空中巴士',
    bg: Color(0xFFF48FB1),
    fg: Color(0xFF880E4F),
  ),
  _Level(
    value: 8192,
    emoji: '🛸',
    name: '航空母艦',
    bg: Color(0xFFFFD54F),
    fg: Color(0xFF4E342E),
  ),
  _Level(
    value: 16384,
    emoji: '🚀',
    name: '太空飛船',
    bg: Color(0xFFFFD700),
    fg: Color(0xFF212121),
  ),
];

_Level? _levelOf(int value) {
  for (final l in _kLevels) {
    if (l.value == value) return l;
  }
  return null;
}

class _Level {
  final int value;
  final String emoji;
  final String name;
  final Color bg;
  final Color fg;
  const _Level({
    required this.value,
    required this.emoji,
    required this.name,
    required this.bg,
    required this.fg,
  });
}

// ══════════════════════════════════════════════════════════

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page>
    with TickerProviderStateMixin {
  static const int _size = 4;

  late List<List<_Tile?>> _board;
  int _score = 0;
  int _best = 0;
  bool _gameOver = false;
  bool _won = false;
  bool _continueAfterWin = false;

  final Map<String, AnimationController> _popControllers = {};
  final Map<String, AnimationController> _mergeControllers = {};
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    for (final c in _popControllers.values) {
      c.dispose();
    }
    for (final c in _mergeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── 遊戲邏輯 ──────────────────────────────────────────

  void _newGame() {
    for (final c in _popControllers.values) {
      c.dispose();
    }
    for (final c in _mergeControllers.values) {
      c.dispose();
    }
    _popControllers.clear();
    _mergeControllers.clear();
    _board = List.generate(_size, (_) => List.filled(_size, null));
    _score = 0;
    _gameOver = false;
    _won = false;
    _continueAfterWin = false;
    _addRandom();
    _addRandom();
    setState(() {});
  }

  void _addRandom() {
    final empty = <_Pos>[];
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_board[r][c] == null) empty.add(_Pos(r, c));
      }
    }
    if (empty.isEmpty) return;
    final pos = empty[Random().nextInt(empty.length)];
    final value = Random().nextDouble() < 0.9 ? 2 : 4;
    final key = '${pos.r}_${pos.c}_${DateTime.now().microsecondsSinceEpoch}';
    _board[pos.r][pos.c] = _Tile(value: value, key: key);
    _triggerPop(key);
  }

  void _triggerPop(String key) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _popControllers[key] = ctrl;
    ctrl.forward().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _triggerMerge(String key) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _mergeControllers[key] = ctrl;
    ctrl.forward(from: 0).then((_) {
      if (mounted) setState(() {});
    });
  }

  bool _move(Direction dir) {
    bool moved = false;
    final newBoard = List.generate(
      _size,
      (_) => List<_Tile?>.filled(_size, null),
    );

    for (int i = 0; i < _size; i++) {
      final line = <_Tile>[];
      for (int j = 0; j < _size; j++) {
        final t = _getTile(dir, i, j);
        if (t != null) line.add(t);
      }
      final merged = <_Tile>[];
      int idx = 0;
      while (idx < line.length) {
        if (idx + 1 < line.length && line[idx].value == line[idx + 1].value) {
          final newVal = line[idx].value * 2;
          final newKey =
              '${i}_${merged.length}_${DateTime.now().microsecondsSinceEpoch}';
          merged.add(_Tile(value: newVal, key: newKey, merged: true));
          _score += newVal;
          if (newVal == 2048 && !_continueAfterWin) _won = true;
          _triggerMerge(newKey);
          idx += 2;
        } else {
          merged.add(line[idx]);
          idx++;
        }
      }
      for (int j = 0; j < _size; j++) {
        final tile = j < merged.length ? merged[j] : null;
        final old = _getTile(dir, i, j);
        if (tile?.value != old?.value) moved = true;
        _setTile(newBoard, dir, i, j, tile);
      }
    }

    if (moved) {
      _board = newBoard;
      if (_score > _best) _best = _score;
      _addRandom();
      if (!_canMove()) _gameOver = true;
    }
    return moved;
  }

  _Tile? _getTile(Direction dir, int i, int j) {
    switch (dir) {
      case Direction.left:
        return _board[i][j];
      case Direction.right:
        return _board[i][_size - 1 - j];
      case Direction.up:
        return _board[j][i];
      case Direction.down:
        return _board[_size - 1 - j][i];
    }
  }

  void _setTile(
    List<List<_Tile?>> b,
    Direction dir,
    int i,
    int j,
    _Tile? tile,
  ) {
    switch (dir) {
      case Direction.left:
        b[i][j] = tile;
        break;
      case Direction.right:
        b[i][_size - 1 - j] = tile;
        break;
      case Direction.up:
        b[j][i] = tile;
        break;
      case Direction.down:
        b[_size - 1 - j][i] = tile;
        break;
    }
  }

  bool _canMove() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_board[r][c] == null) return true;
        if (r + 1 < _size && _board[r][c]!.value == _board[r + 1][c]!.value) {
          return true;
        }
        if (c + 1 < _size && _board[r][c]!.value == _board[r][c + 1]!.value) {
          return true;
        }
      }
    }
    return false;
  }

  void _handleSwipe(Direction dir) {
    if (_gameOver || (_won && !_continueAfterWin)) return;
    setState(() => _move(dir));
  }

  // ── 遊戲結束 Dialog ────────────────────────────────────

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFAF8EF),
        title: const Text(
          '😢 遊戲結束',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        content: Text(
          '最終分數：$_score',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F7A66),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('再玩一次'),
            onPressed: () {
              Navigator.pop(ctx);
              setState(_newGame);
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF776E65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('回上一頁'),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF9C4),
        title: const Text(
          '🚀 你解鎖太空飛船！',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        content: Text(
          '分數：$_score\n恭喜完成所有等級！繼續挑戰更高分？',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEDC22E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Text('🚀'),
            label: const Text('繼續挑戰'),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _continueAfterWin = true);
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF776E65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('重新開始'),
            onPressed: () {
              Navigator.pop(ctx);
              setState(_newGame);
            },
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 在 build 後觸發 dialog（避免在 setState 中直接 showDialog）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gameOver) {
        _gameOver = false; // 防止重複觸發
        _showGameOverDialog();
      } else if (_won && !_continueAfterWin) {
        _won = false;
        _showWinDialog();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF776E65),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🚀 交通工具 2048',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '重新開始',
            onPressed: () => setState(_newGame),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScoreBar(),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '滑動合併相同交通工具，解鎖太空飛船 🚀',
              style: TextStyle(color: Color(0xFF776E65), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // 等級進度列
          _buildLevelBar(),
          const SizedBox(height: 8),
          Expanded(child: Center(child: _buildBoard())),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F7A66),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text(
                      '重新開始',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => setState(_newGame),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF776E65),
                      side: const BorderSide(color: Color(0xFF776E65)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    label: const Text(
                      '回上一頁',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 頂部最高等級進度顯示
  Widget _buildLevelBar() {
    // 找出棋盤上最高的 value
    int maxVal = 0;
    for (final row in _board) {
      for (final t in row) {
        if (t != null && t.value > maxVal) maxVal = t.value;
      }
    }
    final reached = _kLevels.where((l) => l.value <= maxVal).toList();
    final current = reached.isNotEmpty ? reached.last : null;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _kLevels.length,
        itemBuilder: (context, i) {
          final lv = _kLevels[i];
          final unlocked = lv.value <= maxVal;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Tooltip(
              message: lv.name,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: unlocked ? lv.bg : const Color(0xFFCDC1B4),
                  borderRadius: BorderRadius.circular(8),
                  border: current?.value == lv.value
                      ? Border.all(color: Colors.amber, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    unlocked ? lv.emoji : '🔒',
                    style: TextStyle(fontSize: unlocked ? 18 : 14),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreBar() {
    return Container(
      color: const Color(0xFF776E65),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_scoreBox('分數', _score), _scoreBox('最高', _best)],
      ),
    );
  }

  Widget _scoreBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8F7A66),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFEEE4DA),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return GestureDetector(
      onPanStart: (d) => _dragStart = d.localPosition,
      onPanEnd: (d) {
        if (_dragStart == null) return;
        final delta = d.localPosition - _dragStart!;
        _dragStart = null;
        if (delta.distance < 20) return;
        if (delta.dx.abs() > delta.dy.abs()) {
          _handleSwipe(delta.dx > 0 ? Direction.right : Direction.left);
        } else {
          _handleSwipe(delta.dy > 0 ? Direction.down : Direction.up);
        }
      },
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _handleSwipe(Direction.left);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _handleSwipe(Direction.right);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _handleSwipe(Direction.up);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _handleSwipe(Direction.down);
            }
          }
        },
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBBADA0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(children: [_buildEmptyGrid(), _buildTiles()]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGrid() {
    return GridView.builder(
      shrinkWrap: true, // ✨ 加上這一行，強制 GridView 計算自身尺寸
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _size,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _size * _size,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCDC1B4),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTiles() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.0;
        final cellSize = (constraints.maxWidth - gap * (_size + 1)) / _size;
        final widgets = <Widget>[];

        for (int r = 0; r < _size; r++) {
          for (int c = 0; c < _size; c++) {
            final tile = _board[r][c];
            if (tile == null) continue;

            final left = gap + c * (cellSize + gap);
            final top = gap + r * (cellSize + gap);

            final popCtrl = _popControllers[tile.key];
            final mergeCtrl = _mergeControllers[tile.key];

            Widget w = _buildTileWidget(tile, cellSize);

            if (popCtrl != null) {
              w = AnimatedBuilder(
                animation: popCtrl,
                builder: (_, child) => Transform.scale(
                  scale: Curves.elasticOut.transform(popCtrl.value),
                  child: child,
                ),
                child: w,
              );
            } else if (mergeCtrl != null) {
              w = AnimatedBuilder(
                animation: mergeCtrl,
                builder: (context, innerChild) {
                  final t = mergeCtrl.value;
                  final scale = t < 0.5
                      ? 1.0 + t * 0.25
                      : 1.25 - (t - 0.5) * 0.5;
                  return Transform.scale(scale: scale, child: innerChild);
                },
                child: w,
              );
            }

            // ✨ 核心修正：使用絕對不重複的複合式 Key 組合
            // 加上方塊本身 ID、當前的橫縱座標、以及當前數值，確保在多步數或連鎖合併時 UI 不會隱形！
            widgets.add(
              AnimatedPositioned(
                key: ValueKey('${tile.key}_r${r}_c${c}_v${tile.value}'),
                duration: const Duration(milliseconds: 80),
                left: left,
                top: top,
                width: cellSize,
                height: cellSize,
                child: w,
              ),
            );
          }
        }
        return Stack(children: widgets);
      },
    );
  }

  Widget _buildTileWidget(_Tile tile, double size) {
    final lv = _levelOf(tile.value);
    final bg = lv?.bg ?? const Color(0xFF3C3A32);
    final fg = lv?.fg ?? Colors.white;
    final emoji = lv?.emoji ?? '❓';
    final name = lv?.name ?? '${tile.value}';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: bg.withAlpha(140),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: (size * 0.38).clamp(10.0, 100.0)),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              color: fg,
              fontSize: (size * 0.16).clamp(10.0, 100.0),
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── 資料模型 ───────────────────────────────────────────────

class _Tile {
  final int value;
  final String key;
  final bool merged;
  const _Tile({required this.value, required this.key, this.merged = false});
}

class _Pos {
  final int r, c;
  const _Pos(this.r, this.c);
}

enum Direction { left, right, up, down }
