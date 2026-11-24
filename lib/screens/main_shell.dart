import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/mini_player_widget.dart';
import '../widgets/custom_drawer.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'lectures_screen.dart';
import 'quran_screen.dart';
import 'adhkar_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isExitDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.checkPendingNotificationLaunch(context);
    });
  }

  void _onTabChange(int index) {
    if (_currentIndex == index) return;
    setState(() {
      if (index == 0) {
        _tabHistory.clear();
      } else {
        if (_tabHistory.isEmpty || _tabHistory.last != _currentIndex) {
          _tabHistory.add(_currentIndex);
        }
      }
      _currentIndex = index;
    });
  }

  void _handleBack() {
    if (_tabHistory.isNotEmpty) {
      setState(() {
        _currentIndex = _tabHistory.removeLast();
      });
    } else if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _showExitConfirmationDialog(BuildContext context, bool isDark) async {
    if (_isExitDialogShowing) return;
    _isExitDialogShowing = true;

    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textSub = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Do you want to exit?',
                  style: AppTypography.serif(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to exit Sheikh Xuseen Cali Jabuuti?',
            style: AppTypography.sans(
              fontSize: 13.5,
              color: textSub,
              lineHeight: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'STAY',
                style: AppTypography.sans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: textSub,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
                SystemNavigator.pop();
              },
              child: Text(
                'YES',
                style: AppTypography.sans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );

    _isExitDialogShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final screens = [
      HomeScreen(onTabChange: _onTabChange, onOpenDrawer: _openDrawer),
      LecturesScreen(onOpenDrawer: _openDrawer, onBack: _handleBack),
      QuranScreen(onOpenDrawer: _openDrawer, onBack: _handleBack),
      AdhkarScreen(onOpenDrawer: _openDrawer, onBack: _handleBack),
      SettingsScreen(onOpenDrawer: _openDrawer, onBack: _handleBack),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          _handleBack();
        } else {
          await _showExitConfirmationDialog(context, isDark);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.bg(isDark),
        drawer: CustomDrawer(onTabSelected: _onTabChange),
        body: Stack(
          children: [
            // Screens Stack
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),

            // Persistent Floating Mini-Player pinned above Navigation Bar
            if (audio.isMiniPlayerVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 84 + MediaQuery.of(context).padding.bottom,
                child: const MiniPlayerWidget(),
              ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    final items = [
      {'name': 'Hoyga', 'icon': Icons.home},
      {'name': 'Muxaadaro', 'icon': Icons.podcasts},
      {'name': 'Qur\'aan', 'icon': Icons.menu_book},
      {'name': 'Adkaar', 'icon': Icons.auto_awesome},
      {'name': 'Settings', 'icon': Icons.settings},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E).withOpacity(0.97) : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2E2E3E) : AppColors.outlineVariant.withOpacity(0.35),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 6,
        top: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = _currentIndex == index;

          final activeColor = isDark ? const Color(0xFF9D84FF) : AppColors.primaryContainer;
          final inactiveColor = isDark ? const Color(0xFFBDBDBD) : AppColors.onSurfaceVariant;
          final pillBg = isDark ? const Color(0xFF252538) : AppColors.primaryFixed.withOpacity(0.7);

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onTabChange(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected ? pillBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 21,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['name'] as String,
                    style: AppTypography.sans(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
