import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';

class ReciterSelectionSheet extends StatefulWidget {
  const ReciterSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ReciterSelectionSheet(),
    );
  }

  @override
  State<ReciterSelectionSheet> createState() => _ReciterSelectionSheetState();
}

class _ReciterSelectionSheetState extends State<ReciterSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final sheetBg = AppTheme.card(isDark);
    final searchBg = AppTheme.surface(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final dividerColor = AppTheme.divider(isDark);

    final allReciters = audio.availableReciters;

    final filtered = allReciters.where((r) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.nameAr.contains(q) || r.nameEn.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dooro Qaariga Qur\'aanka',
                      style: AppTypography.serif(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Codadka qiraa\'ada tooska ah ee MP3Quran',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: AppTypography.sans(fontSize: 13.5, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Raadi magaca qaariga (Carabi ama English)...',
                  hintStyle: AppTypography.sans(fontSize: 12.5, color: textMuted),
                  prefixIcon: Icon(Icons.search, size: 20, color: textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 16, color: textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Reciters List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Qaarigan lagama helin liiska.',
                      style: AppTypography.sans(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => Divider(height: 1, color: dividerColor),
                    itemBuilder: (ctx, i) {
                      final r = filtered[i];
                      final isSelected = r.id == audio.currentReciter.id;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: isSelected
                            ? (isDark ? AppTheme.darkSecondary : AppColors.primaryFixed.withOpacity(0.3))
                            : Colors.transparent,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                  : dividerColor,
                              width: isSelected ? 2.2 : 1.0,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              r.displayImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.nameEn,
                                style: AppTypography.sans(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              r.nameAr,
                              textDirection: TextDirection.rtl,
                              style: AppTypography.arabic(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : textMuted,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            r.moshafName,
                            style: AppTypography.sans(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 16, color: Colors.white),
                              )
                            : null,
                        onTap: () {
                          audio.setReciter(r);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Waxaa la doortay: ${r.nameEn} (${r.nameAr})'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
