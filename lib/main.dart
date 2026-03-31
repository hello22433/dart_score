import 'package:flutter/material.dart';

void main() {
  runApp(const DartScoreApp());
}

class DartColors {
  static const bg = Color(0xFF111B15);
  static const surface = Color(0xFF182620);
  static const surfaceAlt = Color(0xFF1E2F27);
  static const accent = Color(0xFFCEA64E);
  static const accentBright = Color(0xFFE2BE62);
  static const silver = Color(0xFFB0BAC4);
  static const bronze = Color(0xFFCC8844);
  static const text = Color(0xFFEAE6DE);
  static const textDim = Color(0xFF7E9088);
  static const divider = Color(0xFF2A3E34);
  static const inputBg = Color(0xFF15211B);
  static const red = Color(0xFFCC3333);
}

class DartScoreApp extends StatelessWidget {
  const DartScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '다트 경기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: DartColors.bg,
        useMaterial3: true,
      ),
      home: const ScoreBoardPage(),
    );
  }
}

class Player {
  final int id;
  String name;
  int score;
  String note;

  Player({
    required this.id,
    required this.name,
    required this.score,
    this.note = '',
  });
}

class ScoreBoardPage extends StatefulWidget {
  const ScoreBoardPage({super.key});

  @override
  State<ScoreBoardPage> createState() => _ScoreBoardPageState();
}

class _ScoreBoardPageState extends State<ScoreBoardPage> {
  final List<Player> _players = [];
  int _nextId = 1;

  final _nameController = TextEditingController();
  final _scoreController = TextEditingController();
  final _noteController = TextEditingController();

  Player? _editingPlayer;

  List<Player> get _sortedPlayers {
    final sorted = List<Player>.from(_players);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  void _addOrUpdatePlayer() {
    final name = _nameController.text.trim();
    final scoreText = _scoreController.text.trim();
    final note = _noteController.text.trim();

    if (name.isEmpty || scoreText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이름과 점수를 입력해주세요.'),
          backgroundColor: DartColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final score = int.tryParse(scoreText);
    if (score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('점수는 숫자로 입력해주세요.'),
          backgroundColor: DartColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (_editingPlayer != null) {
        _editingPlayer!.name = name;
        _editingPlayer!.score = score;
        _editingPlayer!.note = note;
        _editingPlayer = null;
      } else {
        _players.add(Player(
          id: _nextId++,
          name: name,
          score: score,
          note: note,
        ));
      }
    });

    _nameController.clear();
    _scoreController.clear();
    _noteController.clear();
  }

  void _selectPlayer(Player player) {
    setState(() {
      _editingPlayer = player;
    });
    _nameController.text = player.name;
    _scoreController.text = player.score.toString();
    _noteController.text = player.note;
  }

  void _cancelEdit() {
    setState(() {
      _editingPlayer = null;
    });
    _nameController.clear();
    _scoreController.clear();
    _noteController.clear();
  }

  void _deletePlayer(Player player) {
    setState(() {
      _players.removeWhere((p) => p.id == player.id);
      if (_editingPlayer?.id == player.id) {
        _editingPlayer = null;
        _nameController.clear();
        _scoreController.clear();
        _noteController.clear();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scoreController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildMedal(int rank) {
    final colors = switch (rank) {
      1 => (const [Color(0xFFE8C252), Color(0xFFB8922E)], const Color(0xFF2A1A00), DartColors.accent),
      2 => (const [Color(0xFFCDD3DB), Color(0xFF99A3B0)], const Color(0xFF1A2030), DartColors.silver),
      3 => (const [Color(0xFFDD9944), Color(0xFFAA6622)], const Color(0xFF2A1800), DartColors.bronze),
      _ => null,
    };

    if (colors == null) {
      return Text('$rank',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: DartColors.textDim,
              fontWeight: FontWeight.w600,
              fontSize: 14));
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors.$1,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: colors.$3.withValues(alpha: 0.35), blurRadius: 6),
        ],
      ),
      child: Center(
        child: Text('$rank',
            style: TextStyle(
                color: colors.$2,
                fontWeight: FontWeight.w900,
                fontSize: 13)),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: DartColors.textDim, fontSize: 13),
      filled: true,
      fillColor: DartColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: DartColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: DartColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: DartColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedPlayers;

    return Scaffold(
      body: Column(
        children: [
          // 헤더
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3A2C), Color(0xFF224838)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DartColors.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'DART SCORE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: DartColors.text,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DartColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: DartColors.accent.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sorted.length}명 참가',
                    style: TextStyle(
                      color: DartColors.accent.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 컬럼 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: DartColors.surfaceAlt,
            child: Row(
              children: [
                _headerCell('순위', flex: 1, align: TextAlign.center),
                _headerCell('이름', flex: 2),
                _headerCell('점수', flex: 1, align: TextAlign.center),
                _headerCell('비고', flex: 2),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Container(height: 1, color: DartColors.accent.withValues(alpha: 0.3)),

          // 리스트
          Expanded(
            child: sorted.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed,
                            size: 48,
                            color: DartColors.divider.withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        const Text('선수를 등록해주세요',
                            style: TextStyle(
                                color: DartColors.textDim,
                                fontSize: 14,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final player = sorted[index];
                      final rank = index + 1;
                      final isEditing = _editingPlayer?.id == player.id;

                      return InkWell(
                        onTap: () => _selectPlayer(player),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: isEditing
                                ? DartColors.accent.withValues(alpha: 0.08)
                                : index.isEven
                                    ? DartColors.surface
                                    : DartColors.bg,
                            border: isEditing
                                ? Border(
                                    left: BorderSide(
                                        color: DartColors.accent, width: 3))
                                : Border(
                                    bottom: BorderSide(
                                        color: DartColors.divider
                                            .withValues(alpha: 0.5),
                                        width: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(child: _buildMedal(rank)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: DartColors.text,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${player.score}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: rank == 1
                                        ? DartColors.accentBright
                                        : DartColors.text,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  player.note,
                                  style: const TextStyle(
                                    color: DartColors.textDim,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                child: IconButton(
                                  icon: Icon(Icons.close,
                                      size: 16,
                                      color: DartColors.textDim
                                          .withValues(alpha: 0.5)),
                                  onPressed: () => _deletePlayer(player),
                                  tooltip: '삭제',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 입력 영역
          Container(
            decoration: BoxDecoration(
              color: DartColors.surface,
              border: Border(
                top: BorderSide(
                    color: DartColors.accent.withValues(alpha: 0.25)),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  if (_editingPlayer != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: DartColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_editingPlayer!.name} 수정 중',
                            style: const TextStyle(
                              color: DartColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _cancelEdit,
                            child: const Text('취소',
                                style: TextStyle(
                                    color: DartColors.textDim,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    decorationColor: DartColors.textDim)),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              color: DartColors.text, fontSize: 14),
                          decoration: _inputDeco('이름'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _scoreController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: DartColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          decoration: _inputDeco('점수'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          style: const TextStyle(
                              color: DartColors.text, fontSize: 14),
                          decoration: _inputDeco('비고'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _addOrUpdatePlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DartColors.accent,
                            foregroundColor: DartColors.bg,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          child: Text(
                            _editingPlayer != null ? '수정' : '추가',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text,
      {required int flex, TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: DartColors.accent.withValues(alpha: 0.8),
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
