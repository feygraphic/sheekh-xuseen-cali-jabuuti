import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';
import '../widgets/arabesque_pattern.dart';
import '../screens/about_sheikh_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onTabSelected;

  const CustomDrawer({
    super.key,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final iconColor = isDark ? AppTheme.primaryLight : AppColors.primary;
    final dividerColor = AppTheme.divider(isDark);

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -30,
                  top: -30,
                  child: ArabesquePattern(size: 150, opacity: 0.15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/sheikh_hero.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sheekh Xuseen Cali Jabuuti',
                      style: AppTypography.sans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الشيخ حسين علي جيبوتي • Daaci & Caalim',
                      style: AppTypography.arabic(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.primaryFixed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Maktabadda Rasmiga Ah',
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Hoyga (Home)',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(0);
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.podcasts_outlined,
                  title: 'Muxaadarooyinka (Lectures)',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(1);
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  title: 'Qur\'aanka & Tafsiirka',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(2);
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.spa_outlined,
                  title: 'Adkaarta & Misbaxada',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(3);
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(4);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(color: dividerColor),
                ),
                _buildItem(
                  context,
                  icon: Icons.share_outlined,
                  title: 'La Wadaag App-ka',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Share.share(
                      'Degso App-ka Sheekh Xuseen Cali Jabuuti oo ka dhageyso Muxaadarooyinka, Tafsiirka Qur\'aanka iyo Adkaarta: https://play.google.com/store/apps',
                    );
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Ku Saabsan Sheekha',
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutSheikhScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              'Nooca 1.0.2 • Sheekh Xuseen Cali Jabuuti',
              style: AppTypography.sans(
                fontSize: 12,
                color: textMuted.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          title,
          style: AppTypography.sans(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
