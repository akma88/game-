import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const UnderwaterRaceApp());
}

class UnderwaterRaceApp extends StatelessWidget {
  const UnderwaterRaceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Deep Rush',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const HomeScreen(),
  );
}

class ScoreRecord {
  final int score, gems;
  final String date;
  ScoreRecord({required this.score, required this.gems, required this.date});
}

class AppState {
  double startSpeed = 2.0;
  int startLives = 3;
  bool showBubbles = true;
  bool showRays = true;
  bool showCreatures = true;
  List<ScoreRecord> records = [];

  void addRecord(int score, int gems) {
    records.add(ScoreRecord(score: score, gems: gems, date: _today()));
    records.sort((a, b) => b.score.compareTo(a.score));
    if (records.length > 10) records = records.sublist(0, 10);
  }

  String _today() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

final appState = AppState();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _goGame() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const GameScreen()));
  void _goRecords() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const RecordsScreen()));
  void _goSettings() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));

  @override
  Widget build(BuildContext context) {
    final best = appState.records.isNotEmpty ? appState.records.first.score : 0;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000D1A),
              Color(0xFF001535),
              Color(0xFF002450),
              Color(0xFF001020),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [
                    Color(0xFF00EEFF),
                    Color(0xFF0066FF),
                    Color(0xFF00EEFF),
                  ],
                ).createShader(b),
                child: const Text(
                  'DEEP RUSH',
                  style: TextStyle(
                    fontSize: 62,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'UNDERWATER RACE',
                style: TextStyle(
                  color: Colors.cyan.shade300,
                  letterSpacing: 6,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),
              if (best > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber.withOpacity(.45)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'РЕКОРД: ${best}m',
                    style: TextStyle(
                      color: Colors.amber.shade300,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 36),
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => GestureDetector(
                  onTap: _goGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 56,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0088FF), Color(0xFF00DDFF)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF00AAFF,
                          ).withOpacity(.35 + .2 * _pulse.value),
                          blurRadius: 30 + 10 * _pulse.value,
                        ),
                      ],
                    ),
                    child: const Text(
                      'НЫРНУТЬ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Зажми / пробел → вверх   •   Отпусти → вниз',
                style: TextStyle(
                  color: Colors.white.withOpacity(.35),
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavBtn('🏆  РЕКОРДЫ', _goRecords),
                  const SizedBox(width: 12),
                  _NavBtn('⚙  НАСТРОЙКИ', _goSettings),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
    ),
  );
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = appState.records;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000D1A), Color(0xFF001535), Color(0xFF002450)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.cyan,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'ТАБЛИЦА РЕКОРДОВ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 11,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? const Center(
                        child: Text(
                          'Рекордов пока нет — сыграй первым! 🐟',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        itemCount: records.length,
                        itemBuilder: (_, i) {
                          final r = records[i];
                          final rankColors = [
                            Colors.amber,
                            Colors.grey.shade400,
                            const Color(0xFFCD7F32),
                          ];
                          final rankLabels = ['🥇', '🥈', '🥉'];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF001E3C).withOpacity(.6),
                              border: Border.all(
                                color: i == 0
                                    ? Colors.cyan.withOpacity(.4)
                                    : Colors.blue.withOpacity(.2),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    i < 3 ? rankLabels[i] : '#${i + 1}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: i < 3
                                          ? rankColors[i]
                                          : Colors.white30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ИГРОК',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text(
                                        '${r.date}  ·  💎 ${r.gems}',
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${r.score}m',
                                  style: const TextStyle(
                                    color: Color(0xFF00DDFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000D1A), Color(0xFF001535), Color(0xFF002450)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.cyan,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'НАСТРОЙКИ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 11,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHead('СЛОЖНОСТЬ'),
                      _SliderCard(
                        label: 'НАЧАЛЬНАЯ СКОРОСТЬ',
                        desc: 'Ниже = легче',
                        value: appState.startSpeed,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        display: appState.startSpeed.toStringAsFixed(1),
                        onChanged: (v) =>
                            setState(() => appState.startSpeed = v),
                      ),
                      _SliderCard(
                        label: 'ЖИЗНЕЙ',
                        desc: 'Стартовое количество',
                        value: appState.startLives.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        display: appState.startLives.toString(),
                        onChanged: (v) =>
                            setState(() => appState.startLives = v.round()),
                      ),
                      _sectionHead('ВНЕШНИЙ ВИД'),
                      _ToggleCard(
                        label: 'ЭФФЕКТ ПУЗЫРЕЙ',
                        desc: 'Анимация пузырьков',
                        value: appState.showBubbles,
                        onChanged: (v) =>
                            setState(() => appState.showBubbles = v),
                      ),
                      _ToggleCard(
                        label: 'ЛУЧИ СВЕТА',
                        desc: 'Каустика',
                        value: appState.showRays,
                        onChanged: (v) => setState(() => appState.showRays = v),
                      ),
                      _ToggleCard(
                        label: 'ФОН. РЫБЫ',
                        desc: 'Морские существа',
                        value: appState.showCreatures,
                        onChanged: (v) =>
                            setState(() => appState.showCreatures = v),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHead(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      t,
      style: TextStyle(
        color: Colors.cyan.withOpacity(.6),
        fontSize: 9,
        letterSpacing: 4,
      ),
    ),
  );
}

class _SliderCard extends StatelessWidget {
  final String label, desc, display;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _SliderCard({
    required this.label,
    required this.desc,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF00141F).withOpacity(.6),
      border: Border.all(color: Colors.blue.withOpacity(.2)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 110,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: Colors.cyan,
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            display,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _ToggleCard extends StatelessWidget {
  final String label, desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleCard({
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF00141F).withOpacity(.6),
      border: Border.all(color: Colors.blue.withOpacity(.2)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, activeColor: Colors.cyan, onChanged: onChanged),
      ],
    ),
  );
}

class Bubble {
  double x, y, radius, speed, opacity;
  Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class Obstacle {
  double x, y, width, height;
  int type;
  Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });
}

class Collectible {
  double x, y;
  bool collected;
  Collectible({required this.x, required this.y, this.collected = false});
}

class SeaCreature {
  double x, y, speed, phase;
  bool facingLeft;
  SeaCreature({
    required this.x,
    required this.y,
    required this.speed,
    required this.facingLeft,
    required this.phase,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool _playing = false, _paused = false, _over = false;
  double _score = 0, _speed = 2.0;
  int _lives = 3, _gems = 0;
  double _py = 0.5, _vy = 0;
  bool _held = false, _invincible = false;
  int _invTimer = 0, _frame = 0;
  double _worldOff = 0;

  late List<Bubble> _bubbles;
  late List<Obstacle> _obstacles;
  late List<Collectible> _collectibles;
  late List<SeaCreature> _creatures;

  Timer? _timer;
  late AnimationController _anim;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _initWorld();
    _startGame();
  }

  void _initWorld() {
    _bubbles = List.generate(
      26,
      (_) => Bubble(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: 2 + _rng.nextDouble() * 7,
        speed: 0.00025 + _rng.nextDouble() * 0.0006,
        opacity: 0.07 + _rng.nextDouble() * 0.28,
      ),
    );
    _creatures = List.generate(
      4,
      (_) => SeaCreature(
        x: 0.3 + _rng.nextDouble() * 0.65,
        y: 0.1 + _rng.nextDouble() * 0.75,
        speed: 0.0005 + _rng.nextDouble() * 0.0009,
        facingLeft: _rng.nextBool(),
        phase: _rng.nextDouble() * pi * 2,
      ),
    );
  }

  void _startGame() {
    _score = 0;
    _lives = appState.startLives;
    _gems = 0;
    _speed = appState.startSpeed;
    _py = 0.5;
    _vy = 0;
    _invincible = false;
    _invTimer = 0;
    _worldOff = 0;
    _frame = 0;
    _obstacles = [];
    _collectibles = [];
    _playing = true;
    _paused = false;
    _over = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _update());
  }

  void _pause() {
    if (!_playing || _paused) return;
    setState(() => _paused = true);
  }

  void _resume() {
    if (!_paused) return;
    setState(() => _paused = false);
  }

  void _doGameOver() {
    _timer?.cancel();
    appState.addRecord(_score.toInt(), _gems);
    setState(() {
      _playing = false;
      _over = true;
    });
  }

  void _update() {
    if (!_playing || _paused) return;
    setState(() {
      _frame++;
      _score += _speed * 0.032;
      _speed =
          (_speed < appState.startSpeed + (_score / 800)
                  ? appState.startSpeed + (_score / 800)
                  : _speed)
              .clamp(appState.startSpeed, 8.0);

      if (_held)
        _vy -= 0.015;
      else
        _vy += 0.009;
      _vy = _vy.clamp(-0.022, 0.022);
      _py = (_py + _vy).clamp(0.05, 0.93);
      _worldOff += _speed;

      if (appState.showBubbles) {
        for (final b in _bubbles) {
          b.y -= b.speed * _speed;
          b.x += sin(_worldOff * 0.01 + b.radius) * 0.00012;
          if (b.y < -0.03) {
            b.y = 1.04;
            b.x = _rng.nextDouble();
          }
        }
      }
      if (appState.showCreatures) {
        for (final c in _creatures) {
          c.x += (c.facingLeft ? -1 : 1) * c.speed * _speed;
          c.phase += 0.035;
          if (c.x < -0.15) {
            c.x = 1.1;
            c.facingLeft = false;
          }
          if (c.x > 1.15) {
            c.x = -0.1;
            c.facingLeft = true;
          }
          c.y = (c.y + sin(c.phase) * 0.0005).clamp(0.05, 0.9);
        }
      }

      final spawnRate = (185 / (_speed * 0.5)).clamp(60.0, 220.0);
      if (_worldOff % spawnRate < _speed) {
        final h = 0.09 + _rng.nextDouble() * 0.2;
        final fromTop = _rng.nextBool();
        _obstacles.add(
          Obstacle(
            x: 1.05,
            y: fromTop ? 0 : 1 - h,
            width: 0.046 + _rng.nextDouble() * 0.034,
            height: h,
            type: _rng.nextInt(3),
          ),
        );
        if (_rng.nextDouble() < 0.42)
          _collectibles.add(
            Collectible(x: 1.07, y: 0.18 + _rng.nextDouble() * 0.64),
          );
      }
      for (final o in _obstacles) o.x -= _speed * 0.006;
      for (final c in _collectibles) c.x -= _speed * 0.006;
      _obstacles.removeWhere((o) => o.x < -0.15);
      _collectibles.removeWhere((c) => c.x < -0.1);

      if (_invTimer > 0)
        _invTimer--;
      else
        _invincible = false;
      if (!_invincible) {
        const pw = 0.055, ph = 0.07, px = 0.15, m = 0.01;
        for (final o in _obstacles) {
          if (px + pw - m > o.x + m &&
              px + m < o.x + o.width - m &&
              _py - ph / 2 + ph - m > o.y + m &&
              _py - ph / 2 + m < o.y + o.height - m) {
            _lives--;
            _invincible = true;
            _invTimer = 90;
            if (_lives <= 0) {
              _doGameOver();
              return;
            }
            break;
          }
        }
      }
      for (final c in _collectibles) {
        if (!c.collected &&
            (c.x - 0.15).abs() < 0.06 &&
            (c.y - _py).abs() < 0.06) {
          c.collected = true;
          _gems++;
          _score += 40;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (_) {
          _held = true;
        },
        onTapUp: (_) {
          _held = false;
        },
        onPanStart: (_) {
          _held = true;
        },
        onPanEnd: (_) {
          _held = false;
        },
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) => LayoutBuilder(
            builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              return Stack(
                children: [
                  CustomPaint(
                    size: size,
                    painter: _BgPainter(
                      _bubbles,
                      _worldOff,
                      _frame,
                      appState.showBubbles,
                      appState.showRays,
                    ),
                  ),
                  if (_playing || _paused)
                    CustomPaint(
                      size: size,
                      painter: _WorldPainter(
                        _py,
                        _frame,
                        _obstacles,
                        _collectibles,
                        _creatures,
                        _invincible,
                        _worldOff,
                        appState.showCreatures,
                      ),
                    ),
                  if (_playing || _paused) _buildHUD(),
                  if (_over) _buildOver(),
                  if (_paused && _playing) _buildPause(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(.65), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ГЛУБИНА',
                style: TextStyle(
                  color: Colors.cyan.shade300,
                  fontSize: 8,
                  letterSpacing: 3,
                ),
              ),
              Text(
                '${_score.toInt()}m',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
          Row(
            children: List.generate(
              appState.startLives,
              (i) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.favorite,
                  color: i < _lives ? Colors.redAccent : Colors.white24,
                  size: 20,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$_gems',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'СКОРОСТЬ',
                style: TextStyle(
                  color: Colors.cyan.shade300,
                  fontSize: 8,
                  letterSpacing: 3,
                ),
              ),
              Text(
                '${_speed.toStringAsFixed(1)}×',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _pause,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOver() => Container(
    color: Colors.black.withOpacity(.75),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'КОНЕЦ',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 50,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_score.toInt()}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '💎 $_gems кристаллов',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OvBtn('ЕЩЁ РАЗ', true, _startGame),
              const SizedBox(width: 12),
              _OvBtn('РЕКОРДЫ', false, () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecordsScreen()),
                );
              }),
              const SizedBox(width: 12),
              _OvBtn('МЕНЮ', false, () => Navigator.pop(context)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildPause() => Container(
    color: Colors.black.withOpacity(.68),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ПАУЗА',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OvBtn('ПРОДОЛЖИТЬ', true, _resume),
              const SizedBox(width: 12),
              _OvBtn('ВЫЙТИ', false, () => Navigator.pop(context)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OvBtn extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _OvBtn(this.label, this.primary, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
      decoration: BoxDecoration(
        gradient: primary
            ? const LinearGradient(
                colors: [Color(0xFF0088FF), Color(0xFF00DDFF)],
              )
            : null,
        color: primary ? null : Colors.transparent,
        border: primary ? null : Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primary ? Colors.white : Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
    ),
  );
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _BgPainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double worldOff;
  final int frame;
  final bool showBubbles, showRays;
  _BgPainter(
    this.bubbles,
    this.worldOff,
    this.frame,
    this.showBubbles,
    this.showRays,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000D1A),
          Color(0xFF001535),
          Color(0xFF002450),
          Color(0xFF001020),
        ],
        stops: [0, 0.4, 0.75, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), g);

    if (showRays) {
      for (int i = 0; i < 7; i++) {
        final x =
            ((i / 7 + worldOff * 0.0004 + sin(frame * .004 + i) * .04) % 1) *
            size.width;
        final rg = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0099FF).withOpacity(.04),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(x, 0, 45, size.height))
          ..blendMode = BlendMode.screen;
        canvas.drawRect(Rect.fromLTWH(x, 0, 45, size.height), rg);
      }
    }

    // surface
    final sf = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF55AAFF).withOpacity(.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 22));
    final sp = Path()..moveTo(0, 0);
    for (double x = 0; x <= size.width; x += 8)
      sp.lineTo(x, 13 + 9 * sin((x / 70 + frame * .018) * pi));
    sp.lineTo(size.width, 0);
    canvas.drawPath(sp, sf);

    // seaweed
    const spos = [.06, .19, .38, .54, .69, .84, .93];
    for (final xf in spos) {
      final sx = ((xf - worldOff * .004) % 1.1 + 1.1) % 1.1 * size.width;
      final sh = 50 + 32 * sin(xf * 10);
      final base = size.height * .88;
      final sw = Paint()
        ..color = const Color(0xFF126320).withOpacity(.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      final wp = Path()..moveTo(sx, base);
      for (int j = 0; j <= 5; j++) {
        final t = j / 5;
        wp.lineTo(
          sx + 10 * sin((frame * .013 + xf * 5 + t * 2) * pi),
          base - sh * t,
        );
      }
      canvas.drawPath(wp, sw);
    }

    // floor
    final fp = Paint()..color = const Color(0xFF6E5C41).withOpacity(.55);
    final floor = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 10)
      floor.lineTo(
        x,
        size.height * .88 +
            11 * sin((x / size.width * 5 + worldOff * .003) * pi),
      );
    floor.lineTo(size.width, size.height);
    canvas.drawPath(floor, fp);

    if (showBubbles) {
      for (final b in bubbles) {
        canvas.save();
        canvas.drawCircle(
          Offset(b.x * size.width, b.y * size.height),
          b.radius,
          Paint()
            ..color = Colors.white.withOpacity(b.opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        canvas.drawCircle(
          Offset(
            b.x * size.width - b.radius * .3,
            b.y * size.height - b.radius * .3,
          ),
          b.radius * .25,
          Paint()..color = Colors.white.withOpacity(b.opacity * .8),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _WorldPainter extends CustomPainter {
  final double py, worldOff;
  final int frame;
  final List<Obstacle> obstacles;
  final List<Collectible> collectibles;
  final List<SeaCreature> creatures;
  final bool invincible, showCreatures;
  _WorldPainter(
    this.py,
    this.frame,
    this.obstacles,
    this.collectibles,
    this.creatures,
    this.invincible,
    this.worldOff,
    this.showCreatures,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final o in obstacles) _drawObs(canvas, size, o);
    for (final c in collectibles) if (!c.collected) _drawGem(canvas, size, c);
    if (showCreatures)
      for (final c in creatures) _drawCreature(canvas, size, c);
    if (!invincible || frame % 6 < 3) _drawPlayer(canvas, size);
    // speed lines
    final lp = Paint()
      ..color = Colors.white.withOpacity(.035)
      ..strokeWidth = 1;
    for (int i = 0; i < 13; i++) {
      final y = (worldOff * .14 + i * (size.height / 13)) % size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width * .22, y), lp);
    }
  }

  void _drawObs(Canvas canvas, Size size, Obstacle o) {
    final x = o.x * size.width,
        y = o.y * size.height,
        w = o.width * size.width,
        h = o.height * size.height;
    if (o.type == 0) {
      for (int i = 0; i < 4; i++) {
        final bx = x + w * (i + .5) / 4;
        canvas.drawPath(
          Path()
            ..moveTo(bx, y + h)
            ..lineTo(bx - 7, y + h * .4)
            ..lineTo(bx, y)
            ..lineTo(bx + 7, y + h * .4)
            ..close(),
          Paint()..color = const Color(0xFF),
        );
        canvas.drawCircle(
          Offset(bx, y),
          7,
          Paint()..color = const Color(0xFFFF6688),
        );
      }
    } else if (o.type == 1) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x + w / 2, y + h * .28),
          width: w,
          height: h * .5,
        ),
        pi,
        pi,
        true,
        Paint()
          ..color = const Color(0xFFCC44FF).withOpacity(.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      final tp = Paint()
        ..color = const Color(0xFF8C19BE).withOpacity(.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (int i = 0; i < 5; i++) {
        final tx = x + w * (i + .5) / 5;
        final tPath = Path()..moveTo(tx, y + h * .35);
        for (double j = 0; j < h * .65; j += 10)
          tPath.relativeLineTo(7 * (i % 2 == 0 ? 1 : -1), 10);
        canvas.drawPath(tPath, tp);
      }
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(x + w * .2, y + h)
          ..lineTo(x, y + h * .7)
          ..lineTo(x + w * .15, y)
          ..lineTo(x + w * .5, y + h * .1)
          ..lineTo(x + w * .9, y)
          ..lineTo(x + w, y + h * .75)
          ..lineTo(x + w * .85, y + h)
          ..close(),
        Paint()..color = const Color(0xFF4A5F72),
      );
    }
  }

  void _drawGem(Canvas canvas, Size size, Collectible c) {
    final cx = c.x * size.width, cy = c.y * size.height, r = 9.0;
    final p = 0.8 + .2 * sin(frame * .07 + cx);
    canvas.save();
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - r)
        ..lineTo(cx + r * .7, cy - r * .2)
        ..lineTo(cx + r * .5, cy + r)
        ..lineTo(cx - r * .5, cy + r)
        ..lineTo(cx - r * .7, cy - r * .2)
        ..close(),
      Paint()
        ..color = Colors.amber.withOpacity(p)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();
  }

  void _drawCreature(Canvas canvas, Size size, SeaCreature c) {
    final cx = c.x * size.width, cy = c.y * size.height;
    canvas.save();
    canvas.translate(cx, cy);
    if (!c.facingLeft) canvas.scale(-1, 1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 32, height: 16),
      Paint()..color = const Color(0xFFFF7832).withOpacity(.52),
    );
    final tail = sin(c.phase) * 5;
    canvas.drawPath(
      Path()
        ..moveTo(-14, 0)
        ..lineTo(-22, -6 + tail)
        ..lineTo(-18, 0)
        ..lineTo(-22, 6 + tail)
        ..close(),
      Paint()..color = const Color(0xFFC8501E).withOpacity(.52),
    );
    canvas.drawCircle(
      const Offset(9, -2),
      4,
      Paint()..color = Colors.white.withOpacity(.85),
    );
    canvas.drawCircle(
      const Offset(10, -2),
      2,
      Paint()..color = Colors.black.withOpacity(.8),
    );
    canvas.restore();
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final cx = 0.15 * size.width,
        cy = py * size.height,
        tail = sin(frame * .16) * 11;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 60, height: 30),
      Paint()
        ..shader =
            const LinearGradient(
              colors: [Color(0xFF00DDFF), Color(0xFF0055DD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(
              Rect.fromCenter(center: Offset.zero, width: 60, height: 30),
            )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-26, 0)
        ..lineTo(-42, -11 + tail)
        ..lineTo(-36, 0)
        ..lineTo(-42, 11 + tail)
        ..close(),
      Paint()..color = const Color(0xFF0044CC),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-2, -14)
        ..lineTo(9, -25 + tail * .4)
        ..lineTo(18, -14)
        ..close(),
      Paint()..color = const Color(0xFF00C8FF).withOpacity(.8),
    );
    canvas.drawCircle(const Offset(19, -4), 7, Paint()..color = Colors.white);
    canvas.drawCircle(
      const Offset(21, -4),
      4,
      Paint()..color = const Color(0xFF001833),
    );
    canvas.drawCircle(const Offset(22, -5), 1.5, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => true;
}
