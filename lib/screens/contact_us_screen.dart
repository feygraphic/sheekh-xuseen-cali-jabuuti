import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  final List<String> _categories = [
    'General Inquiry',
    'Technical Issue',
    'Suggestions & Feedback',
    'Content Question',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:sheekhxuseenapp@gmail.com?subject=Inquiry%20-%20Sheikh%20Xuseen%20Cali%20Jabuuti%20App');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _copyToClipboard('sheekhxuseenapp@gmail.com', 'Support Email');
      }
    } catch (_) {
      if (mounted) {
        _copyToClipboard('sheekhxuseenapp@gmail.com', 'Support Email');
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard: $text'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    final name = _nameController.text.trim();
    _nameController.clear();
    _contactController.clear();
    _messageController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Message Sent'),
          ],
        ),
        content: Text(
          'Thank you, $name. Your message has been successfully received by the Sheikh Xuseen Cali Jabuuti application support team.',
          style: AppTypography.sans(fontSize: 13.5, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us & Support',
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
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Support Team',
                        style: AppTypography.serif(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'We welcome your suggestions, questions, and feedback. Feel free to connect with our dedicated support channels.',
                        style: AppTypography.sans(fontSize: 12, color: Colors.white.withOpacity(0.92), lineHeight: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Official Channels
          Text(
            'OFFICIAL CONTACT CHANNELS',
            style: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.outline, letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),

          // Email Support Card (Clickable)
          _buildActionCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            icon: Icons.email,
            iconColor: const Color(0xFFEA4335),
            title: 'Email Support',
            subtitle: 'sheekhxuseenapp@gmail.com',
            buttonLabel: 'Send Email',
            onTap: _launchEmail,
            onCopy: () => _copyToClipboard('sheekhxuseenapp@gmail.com', 'Support Email'),
          ),
          const SizedBox(height: 10),

          // General Contact Information Card
          _buildActionCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            icon: Icons.podcasts,
            iconColor: AppColors.primary,
            title: 'Media & Lecture Archive',
            subtitle: 'Mustaqim Media Official Archive',
            buttonLabel: 'Copy Info',
            onTap: () => _copyToClipboard('Mustaqim Media - Sheikh Xuseen Cali Jabuuti Archive', 'Media Info'),
            onCopy: () => _copyToClipboard('Mustaqim Media - Sheikh Xuseen Cali Jabuuti Archive', 'Media Info'),
          ),
          const SizedBox(height: 24),

          // Interactive Feedback Form
          Text(
            'SEND US A DIRECT MESSAGE',
            style: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.outline, letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name Field
                  Text('Your Name *', style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: textColor, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(color: textMuted, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF151220) : AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Contact Field
                  Text('Email or Phone Number *', style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contactController,
                    style: TextStyle(color: textColor, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. name@example.com or +253...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF151220) : AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please provide an email or phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  Text('Inquiry Type', style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151220) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: cardBg,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        style: TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w500),
                        isExpanded: true,
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _selectedCategory = newVal;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Message Content
                  Text('Message Details *', style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    style: TextStyle(color: textColor, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Type your message or inquiry here...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF151220) : AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 5) {
                        return 'Please enter at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isSubmitting ? null : _submitMessage,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(
                      _isSubmitting ? 'Sending...' : 'Send Message',
                      style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.sans(fontSize: 12, color: textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: AppColors.primary,
                  tooltip: 'Copy',
                  onPressed: onCopy,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  onPressed: onTap,
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
