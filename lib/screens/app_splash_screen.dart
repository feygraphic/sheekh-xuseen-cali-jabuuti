import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';
import '../widgets/arabesque_pattern.dart';
import '../widgets/rub_el_hizb_icon.dart';
import 'main_shell.dart';

/// Professional Islamic-themed Splash Screen for Sheikh Xuseen Cali Jabuuti App.
/// Features Sheikh Xuseen's photograph, Islamic arch aesthetic, subtle animations,
/// and smooth transition into MainShell.
class AppSplashScreen extends StatefulWidget {
  final bool autoNavigate;

  const AppSplashScreen({
    super.key,
    this.autoNavigate = true,
  });

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _navTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _navTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!mounted || _isNavigating) return;
        _proceedToHome();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('assets/images/sheikh_portrait_new.jpg'),
      context,
    ).catchError((_) {});
  }

  void _proceedToHome() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    _navTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;

    // Palette: Luxurious Royal Purple to Deep Night
    final gradientColors = isDark
        ? [
            const Color(0xFF140726),
            const Color(0xFF1E0B38),
            const Color(0xFF100420),
          ]
        : [
            const Color(0xFF2E1065),
            const Color(0xFF381E72),
            const Color(0xFF21005D),
          ];

    return Scaffold(
      backgroundColor: gradientColors[1],
      body: GestureDetector(
        onTap: _proceedToHome,
        child: Stack(
          children: [
            // 1. Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColors,
                  ),
                ),
              ),
            ),

            // 2. Subtle Islamic Arabesque Patterns (Top-Right & Bottom-Left)
            const Positioned(
              top: -40,
              right: -40,
              child: ArabesquePattern(
                size: 260,
                opacity: 0.10,
                color: Colors.white,
              ),
            ),
            const Positioned(
              bottom: -50,
              left: -50,
              child: ArabesquePattern(
                size: 240,
                opacity: 0.08,
                color: Colors.white,
              ),
            ),

            // 3. Central Branded Card & Identity
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 3),

                            // Bismillah / Islamic Crest
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 1,
                                  color: const Color(0xFFC4B5FD).withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                const RubElHizbIcon(
                                  size: 16,
                                  color: Color(0xFFC4B5FD),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  style: AppTypography.arabic(
                                    fontSize: 15,
                                    color: const Color(0xFFDDD6FE),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const RubElHizbIcon(
                                  size: 16,
                                  color: Color(0xFFC4B5FD),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 24,
                                  height: 1,
                                  color: const Color(0xFFC4B5FD).withOpacity(0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Sheikh Xuseen Cali Jabuuti Portrait Card
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6B21A8).withOpacity(0.45),
                                    blurRadius: 36,
                                    spreadRadius: 6,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFC4B5FD).withOpacity(0.75),
                                  width: 2.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(29),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.asset(
                                        'assets/images/sheikh_portrait_new.jpg',
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: const Color(0xFF381E72),
                                          child: const Center(
                                            child: Icon(Icons.person, color: Colors.white, size: 64),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Subtle inner glow overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(29),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // App Title
                            Text(
                              'Sheekh Xuseen Cali Jabuuti',
                              textAlign: TextAlign.center,
                              style: AppTypography.serif(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Somali Subtitle
                            Text(
                              'Maktabadda Muxaadarooyinka iyo Duruusta',
                              textAlign: TextAlign.center,
                              style: AppTypography.sans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFC4B5FD),
                                letterSpacing: 0.4,
                              ),
                            ),

                            const Spacer(flex: 3),

                            // Subtle Elegant Loading Indicator
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFC4B5FD).withOpacity(0.85),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Footer Version Tag
                            Text(
                              'Nooca 1.0.2 • Daabacaadda Rasmiga ah',
                              style: AppTypography.sans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.45),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
