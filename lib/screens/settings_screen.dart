import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import 'about_sheikh_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_us_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    required this.onOpenDrawer,
    this.onBack,
  });

  Future<void> _pickPrayerTime(BuildContext context, SettingsProvider settings, String key, String name) async {
    final currentStr = settings.getPrayerTime(key);
    final parts = currentStr.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 12 : 12;
    final initialMin = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMin),
      helpText: 'Select reminder time for $name prayer',
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await settings.setPrayerTime(key, formatted);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name prayer reminder time updated to: $formatted'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  String _formatDisplayTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.isEmpty) return timeStr;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickAdhkarTime(BuildContext context, SettingsProvider settings, bool isMorning) async {
    final currentStr = isMorning ? settings.adhkarMorningTime : settings.adhkarEveningTime;
    final parts = currentStr.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? (isMorning ? 6 : 17) : (isMorning ? 6 : 17);
    final initialMin = parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30;

    final label = isMorning ? 'Morning Adhkar' : 'Evening Adhkar';

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMin),
      helpText: 'Select reminder time for $label',
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isMorning) {
        await settings.setMorningAdhkarTime(formatted);
      } else {
        await settings.setEveningAdhkarTime(formatted);
      }
      if (context.mounted) {
        final displayTime = _formatDisplayTime(formatted);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label reminder time updated to: $displayTime'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF13111C) : AppColors.background).withOpacity(0.92),
            border: Border(
              bottom: BorderSide(
                color: borderColor,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      onBack != null ? Icons.arrow_back_rounded : Icons.menu,
                      size: 24,
                      color: textColor,
                    ),
                    tooltip: onBack != null ? 'Dib u noqo' : 'Menu Drawer',
                    onPressed: onBack ?? onOpenDrawer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHEIKH XUSEEN CALI JABUUTI',
                          style: AppTypography.sans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFB49EFF) : AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Settings',
                          style: AppTypography.serif(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        children: [
          // 1. THEME & APPEARANCE
          _buildSectionHeader('1. THEME & APPEARANCE'),
          const SizedBox(height: 8),
          _buildThemeCard(context, settings, cardBg, borderColor, textColor, textMuted, isDark),
          const SizedBox(height: 18),

          // 2. PRAYER NOTIFICATIONS
          _buildSectionHeader('2. PRAYER NOTIFICATIONS'),
          const SizedBox(height: 8),
          _buildPrayerNotificationsCard(context, settings, cardBg, borderColor, textColor, textMuted, isDark),
          const SizedBox(height: 18),

          // 3. ADHKAR REMINDERS
          _buildSectionHeader('3. ADHKAR REMINDERS'),
          const SizedBox(height: 8),
          _buildAdhkarReminderCard(context, settings, cardBg, borderColor, textColor, textMuted, isDark),
          const SizedBox(height: 18),

          // 4. ABOUT THE SCHOLAR
          _buildSectionHeader('4. ABOUT THE SCHOLAR'),
          const SizedBox(height: 8),
          _buildNavigationTile(
            context: context,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            leadingWidget: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/sheikh_hero.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, size: 14, color: AppColors.primary),
                ),
              ],
            ),
            title: 'About Sheikh Xuseen Cali Jabuuti',
            subtitle: 'Learn about the Sheikh\'s biography, Islamic education, scholarly contributions, lectures, and Dawah journey.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutSheikhScreen()),
              );
            },
          ),
          const SizedBox(height: 18),

          // 5. PRIVACY POLICY
          _buildSectionHeader('5. PRIVACY POLICY'),
          const SizedBox(height: 8),
          _buildNavigationTile(
            context: context,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            leadingWidget: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF2C2542) : AppColors.primary.withOpacity(0.12)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 24),
            ),
            title: 'Privacy Policy',
            subtitle: 'Learn how your information is handled, protected, and used within this application.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const SizedBox(height: 18),

          // 6. CONTACT US
          _buildSectionHeader('6. CONTACT & SUPPORT'),
          const SizedBox(height: 8),
          _buildNavigationTile(
            context: context,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            leadingWidget: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E352C) : Colors.green.withOpacity(0.12)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: Colors.green, size: 24),
            ),
            title: 'Contact Us & Support',
            subtitle: 'Get in touch with our team for assistance, feedback, and inquiries.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 1. Theme Card
  Widget _buildThemeCard(
    BuildContext context,
    SettingsProvider settings,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.light_mode, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Light Mode',
                  style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600, color: textColor),
                ),
              ],
            ),
            subtitle: Text('Bright layout ideal for daytime reading', style: TextStyle(color: textMuted, fontSize: 12)),
            value: 'light',
            groupValue: settings.themeMode,
            activeColor: AppColors.primary,
            onChanged: (val) {
              if (val != null) settings.setThemeMode(val);
            },
          ),
          Divider(height: 1, color: borderColor),
          RadioListTile<String>(
            title: Row(
              children: [
                const Icon(Icons.dark_mode, size: 20, color: Color(0xFFB49EFF)),
                const SizedBox(width: 8),
                Text(
                  'Dark Mode',
                  style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600, color: textColor),
                ),
              ],
            ),
            subtitle: Text('Dark layout comfortable for your eyes at night', style: TextStyle(color: textMuted, fontSize: 12)),
            value: 'dark',
            groupValue: settings.themeMode,
            activeColor: const Color(0xFFB49EFF),
            onChanged: (val) {
              if (val != null) settings.setThemeMode(val);
            },
          ),
        ],
      ),
    );
  }

  // 2. Prayer Notifications Card
  Widget _buildPrayerNotificationsCard(
    BuildContext context,
    SettingsProvider settings,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    final prayers = [
      {'key': 'fajr', 'name': 'Fajr (Dawn)', 'arabic': 'الفجر'},
      {'key': 'dhuhr', 'name': 'Dhuhr (Noon)', 'arabic': 'الظهر'},
      {'key': 'asr', 'name': 'Asr (Afternoon)', 'arabic': 'العصر'},
      {'key': 'maghrib', 'name': 'Maghrib (Sunset)', 'arabic': 'المغرب'},
      {'key': 'isha', 'name': 'Isha (Night)', 'arabic': 'العشاء'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 22),
            ),
            title: Text(
              '5 Daily Prayer Notifications',
              style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              'Daily reminders for prayer times',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            value: settings.prayerNotificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => settings.setPrayerNotificationsEnabled(val),
          ),
          if (settings.prayerNotificationsEnabled) ...[
            Divider(height: 1, color: borderColor),
            ...prayers.map((p) {
              final key = p['key']!;
              final name = p['name']!;
              final arabic = p['arabic']!;
              final isEnabled = settings.isPrayerEnabled(key);
              final time = settings.getPrayerTime(key);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: AppTypography.sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isEnabled ? textColor : textMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                arabic,
                                style: AppTypography.arabic(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: isEnabled ? () => _pickPrayerTime(context, settings, key, name) : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 13, color: isEnabled ? AppColors.primary : textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isEnabled ? AppColors.primary : textMuted,
                                    decoration: isEnabled ? TextDecoration.underline : TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isEnabled)
                                  const Icon(Icons.edit, size: 12, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) => settings.togglePrayerItem(key, val),
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                icon: const Icon(Icons.notifications_none, size: 16),
                label: const Text('Test Prayer Reminder'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.mosque, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('Prayer Time: Allahu Akbar, it is time for prayer!'),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 3. Adhkar Reminder Card
  Widget _buildAdhkarReminderCard(
    BuildContext context,
    SettingsProvider settings,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textMuted,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa, color: Colors.orange, size: 22),
            ),
            title: Text(
              'Daily Adhkar Reminders',
              style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              'Reminders for morning and evening remembrance',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            value: settings.adhkarReminderEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => settings.setAdhkarReminderEnabled(val),
          ),
          if (settings.adhkarReminderEnabled) ...[
            Divider(height: 1, color: borderColor),
            // Morning Adhkar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Morning Adhkar',
                          style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: settings.adhkarMorningEnabled ? () => _pickAdhkarTime(context, settings, true) : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDisplayTime(settings.adhkarMorningTime),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: settings.adhkarMorningEnabled ? AppColors.primary : textMuted,
                                  decoration: settings.adhkarMorningEnabled ? TextDecoration.underline : TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (settings.adhkarMorningEnabled)
                                const Icon(Icons.edit, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.adhkarMorningEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => settings.setMorningAdhkarEnabled(val),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            // Evening Adhkar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.nights_stay, color: Color(0xFF7B5BF6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evening Adhkar',
                          style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: settings.adhkarEveningEnabled ? () => _pickAdhkarTime(context, settings, false) : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDisplayTime(settings.adhkarEveningTime),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: settings.adhkarEveningEnabled ? AppColors.primary : textMuted,
                                  decoration: settings.adhkarEveningEnabled ? TextDecoration.underline : TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (settings.adhkarEveningEnabled)
                                const Icon(Icons.edit, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.adhkarEveningEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => settings.setEveningAdhkarEnabled(val),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                icon: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text('Test Adhkar Reminder'),
                onPressed: () async {
                  final isMorning = DateTime.now().hour < 12;
                  await NotificationService.instance.showTestNotification(isMorning: isMorning);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isMorning
                                    ? 'Morning Adhkar reminder notification sent! Tap it to open.'
                                    : 'Evening Adhkar reminder notification sent! Tap it to open.',
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper for options 4, 5, 6
  Widget _buildNavigationTile({
    required BuildContext context,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required Widget leadingWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                leadingWidget,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: AppTypography.sans(
                          fontSize: 12,
                          color: textMuted,
                          lineHeight: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primary.withOpacity(0.8), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.sans(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.outline,
        letterSpacing: 0.8,
      ),
    );
  }
}
