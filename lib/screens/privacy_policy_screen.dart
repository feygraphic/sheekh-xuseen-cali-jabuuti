import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: AppTypography.serif(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Header summary badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Privacy is Our Priority',
                        style: AppTypography.sans(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'This application does not collect, track, or sell personal data. All features are free and privacy-focused.',
                        style: AppTypography.sans(fontSize: 12, color: textMuted, lineHeight: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Introduction
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '1',
            title: 'Introduction',
            content:
                'The Sheikh Xuseen Cali Jabuuti application is developed to serve the Muslim community by providing easy, dependable access to Islamic lectures, the Holy Quran with Somali translation, online recitation streaming, and daily authentic Adhkar. This Privacy Policy details our transparent commitment to your privacy and outlines how data is handled within the application.',
          ),
          const SizedBox(height: 12),

          // 2. Information Collection
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '2',
            title: 'Information Collection',
            content:
                'We do NOT collect, harvest, sell, or rent any personally identifiable information (PII). You are never asked to register an account, log in, or provide your real name, email address, phone number, physical location, or financial payment details. The application functions completely without user registration.',
          ),
          const SizedBox(height: 12),

          // 3. Data Usage
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '3',
            title: 'Data Usage',
            content:
                'Any data created through your use of the application—such as bookmarked Surahs, last-read Quran reading positions, selected audio reciters, saved prayer notification times, and digital Tasbeeh counter counts—is utilized exclusively on your local device to personalize and preserve your reading and listening session states.',
          ),
          const SizedBox(height: 12),

          // 4. Data Protection
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '4',
            title: 'Data Protection',
            content:
                'All application preferences and reading history are stored securely within your device\'s private sandbox storage using local shared preferences. This local data never leaves your device and is not synchronized to external servers. External content transmissions (such as streaming audio) are conducted strictly over encrypted HTTPS protocols.',
          ),
          const SizedBox(height: 12),

          // 5. App Permissions
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '5',
            title: 'App Permissions',
            content:
                'The application requests only minimal permissions necessary for its intended core features:\n\n'
                '• Internet Access: Enables online audio streaming of Quran recitations from MP3Quran API and lecture streams from Backblaze B2 cloud storage.\n'
                '• Notifications: Used solely if you explicitly enable the 5 daily prayer alerts or morning and evening Adhkar reminders.\n'
                '• Foreground Audio Playback: Allows continuous audio listening when navigating through the app or locking the screen.\n\n'
                'We never request access to your device camera, microphone, GPS coordinates, contacts, text messages, or photo library.',
          ),
          const SizedBox(height: 12),

          // 6. Third-Party Services
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '6',
            title: 'Third-Party Services',
            content:
                'To deliver reliable Islamic resources, the application interfaces with established public and cloud services:\n\n'
                '• MP3Quran API: Provides public audio recitation streams for all 114 Surahs from verified Quranic reciters.\n'
                '• QuranEnc API & Tanzil Project: Sources for the verified Somali translation and Uthmani Quranic script.\n'
                '• Backblaze B2: Secure, reliable cloud storage for Sheikh Xuseen Cali Jabuuti\'s lecture audio files.\n\n'
                'The application contains no third-party advertisements, tracking pixels, analytics SDKs, or user profiling tools.',
          ),
          const SizedBox(height: 12),

          // 7. User Privacy & Control
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '7',
            title: 'User Privacy & Control',
            content:
                'You maintain complete control over your application settings. You can enable or disable prayer reminders, modify reminder times, toggle between Light and Dark mode, or reset your saved bookmarks and reading progress at any time by clearing application storage in your device settings.',
          ),
          const SizedBox(height: 12),

          // 8. Contact Information
          _buildPolicyCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            number: '8',
            title: 'Contact Information',
            content:
                'If you have questions, feedback, or concerns regarding this Privacy Policy or the data practices of the Sheikh Xuseen Cali Jabuuti application, please feel free to reach our team at:\n\n'
                '• Email: sheekhxuseenapp@gmail.com\n'
                '• Support: Via the Contact Us & Support page within this application.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.serif(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTypography.sans(
              fontSize: 13,
              color: textMuted,
              lineHeight: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
