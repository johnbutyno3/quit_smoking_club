import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  final Random _random = Random();
  late List<List<int>> _solution;
  late List<List<int>> _board;
  late List<List<bool>> _fixed;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _mistakes = 0;
  int _hints = 3;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final solution = _generateSolution();
    final board = solution.map((row) => [...row]).toList();
    final positions = List.generate(81, (index) => index)..shuffle(_random);
    for (final position in positions.take(42)) {
      board[position ~/ 9][position % 9] = 0;
    }

    setState(() {
      _solution = solution;
      _board = board;
      _fixed = List.generate(
        9,
        (r) => List.generate(9, (c) => board[r][c] != 0),
      );
      _selectedRow = -1;
      _selectedCol = -1;
      _mistakes = 0;
      _hints = 3;
    });
  }

  List<List<int>> _generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));

    bool fill(int index) {
      if (index == 81) return true;
      final row = index ~/ 9;
      final col = index % 9;
      final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

      for (final number in numbers) {
        if (!_canPlace(grid, row, col, number)) continue;
        grid[row][col] = number;
        if (fill(index + 1)) return true;
        grid[row][col] = 0;
      }
      return false;
    }

    fill(0);
    return grid;
  }

  bool _canPlace(List<List<int>> grid, int row, int col, int value) {
    for (var i = 0; i < 9; i++) {
      if (grid[row][i] == value || grid[i][col] == value) return false;
    }
    final boxRow = row ~/ 3 * 3;
    final boxCol = col ~/ 3 * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  void _select(int row, int col) {
    if (_fixed[row][col]) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _enterNumber(int value) {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_fixed[_selectedRow][_selectedCol]) return;

    final row = _selectedRow;
    final col = _selectedCol;
    if (value == _solution[row][col]) {
      setState(() => _board[row][col] = value);
      _checkComplete();
    } else {
      setState(() => _mistakes++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sudokuWrongNumber),
          duration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  void _erase() {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_fixed[_selectedRow][_selectedCol]) return;
    setState(() => _board[_selectedRow][_selectedCol] = 0);
  }

  void _useHint() {
    if (_hints <= 0 || _selectedRow < 0 || _selectedCol < 0) return;
    if (_fixed[_selectedRow][_selectedCol]) return;

    final row = _selectedRow;
    final col = _selectedCol;
    setState(() {
      _board[row][col] = _solution[row][col];
      _hints--;
    });
    _checkComplete();
  }

  void _checkComplete() {
    for (final row in _board) {
      if (row.contains(0)) return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sudokuCompleted),
        content: Text(
          AppLocalizations.of(context)!.sudokuResult(_mistakes),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newGame();
            },
            child: Text(AppLocalizations.of(context)!.sudokuNewGame),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text(l10n.sudokuTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.sudokuNewGame,
            onPressed: _newGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(child: _statCard(l10n.sudokuMistakes, '$_mistakes')),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(l10n.sudokuHints, '$_hints')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.sudokuInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 8, color: Color(0x22000000)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                          ),
                          itemCount: 81,
                          itemBuilder: (context, index) {
                            final row = index ~/ 9;
                            final col = index % 9;
                            return _cell(row, col);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _numberPad(l10n),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _cell(int row, int col) {
    final selected = row == _selectedRow && col == _selectedCol;
    final sameValue =
        _selectedRow >= 0 &&
        _selectedCol >= 0 &&
        _board[row][col] != 0 &&
        _board[row][col] == _board[_selectedRow][_selectedCol];
    final thickRight = col == 2 || col == 5;
    final thickBottom = row == 2 || row == 5;

    return GestureDetector(
      onTap: () => _select(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFC8E6C9)
              : sameValue
                  ? const Color(0xFFE8F5E9)
                  : Colors.white,
          border: Border(
            right: BorderSide(
              color: thickRight ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
              width: thickRight ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: thickBottom ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
              width: thickBottom ? 2 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: Text(
            _board[row][col] == 0 ? '' : '${_board[row][col]}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: _fixed[row][col] ? FontWeight.w800 : FontWeight.w500,
              color: _fixed[row][col]
                  ? const Color(0xFF263238)
                  : const Color(0xFF1B5E20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberPad(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: List.generate(9, (index) {
              final value = index + 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ElevatedButton(
                    onPressed: () => _enterNumber(value),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '$value',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _erase,
                icon: const Icon(Icons.backspace_outlined),
                label: Text(l10n.sudokuErase),
              ),
              const SizedBox(width: 18),
              TextButton.icon(
                onPressed: _useHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(l10n.sudokuUseHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
