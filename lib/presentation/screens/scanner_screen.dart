// lib/presentation/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de produits'),
        backgroundColor: Colors.white,
        foregroundColor: FreshTheme.midnightGray,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) => Transform.scale(
                    scale: _pulse.value,
                    child: child,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: FreshTheme.primaryMint,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: FreshTheme.primaryMint.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Corner accents
                          _corner(Alignment.topLeft),
                          _corner(Alignment.topRight),
                          _corner(Alignment.bottomLeft),
                          _corner(Alignment.bottomRight),

                          // Hint label
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'Pointez vers le code-barres',
                                style: TextStyle(
                                  color: FreshTheme.midnightGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    label: const Text('Recherche manuelle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Depuis la galerie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FreshTheme.primaryMint,
                      side: const BorderSide(color: FreshTheme.primaryMint),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _corner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(
            painter: _CornerPainter(color: FreshTheme.primaryMint),
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Draw L-shape corner
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.6, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}
