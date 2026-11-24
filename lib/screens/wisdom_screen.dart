import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wisdom_provider.dart';
import '../services/wisdom_service.dart';
import '../widgets/wisdom_card_widget.dart';
import '../widgets/rub_el_hizb_icon.dart';

class WisdomScreen extends StatefulWidget {
  final String? initialCategory;

  const WisdomScreen({super.key, this.initialCategory});

  @override
  State<WisdomScreen> createState() => _WisdomScreenState();
}

class _WisdomScreenState extends State<WisdomScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WisdomProvider>(context, listen: false);
      if (widget.initialCategory != null) {
        provider.setCategory(widget.initialCategory!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final wisdomProvider = Provider.of<WisdomProvider>(context);
    final favProvider = Provider.of<FavoritesProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textSub = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final filteredList = wisdomProvider.getFilteredWisdom(favProvider);
    final featuredWisdom = wisdomProvider.currentCarouselWisdom;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          tooltip: 'Dib u noqo (Back)',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'HIKMADO IYO HADALLO QAALI AH',
              style: AppTypography.sans(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Islamic Wisdom & Sayings',
              style: AppTypography.serif(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Search Toggle
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: textColor,
              size: 22,
            ),
            tooltip: 'Raadi (Search)',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  wisdomProvider.setSearchQuery('');
                }
              });
            },
          ),
          // Favorites Toggle
          IconButton(
            icon: Icon(
              wisdomProvider.showOnlyFavorites
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: wisdomProvider.showOnlyFavorites
                  ? const Color(0xFFEF4444)
                  : textColor,
              size: 22,
            ),
            tooltip: 'Xikmadaha Kaydsan',
            onPressed: () {
              wisdomProvider.toggleShowOnlyFavorites();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar (when toggled)
            if (_isSearchVisible)
              Container(
                color: cardBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: AppTypography.sans(fontSize: 14, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Ku raadi eray, caalim, ama mowduuc...',
                    hintStyle: AppTypography.sans(fontSize: 13, color: textSub),
                    prefixIcon: Icon(Icons.search, size: 20, color: accentColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              wisdomProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppTheme.darkInputFill : AppTheme.lightInputFill,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    wisdomProvider.setSearchQuery(val);
                  },
                ),
              ),

            // 2. Category Filter Pills (Horizontal Scroll)
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: WisdomService.categories.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = WisdomService.categories[i];
                  final isSelected = wisdomProvider.selectedCategory == cat.id;
                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      wisdomProvider.setCategory(cat.id);
                    },
                    selectedColor: accentColor,
                    backgroundColor: cardBg,
                    labelStyle: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : textColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                      side: BorderSide(
                        color: isSelected ? accentColor : borderColor,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  );
                },
              ),
            ),

            // 3. Speaker Filter Dropdown / Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, size: 16, color: textSub),
                  const SizedBox(width: 6),
                  Text(
                    'Qofka Laga Soo Xigtay:',
                    style: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSub,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: wisdomProvider.selectedSpeaker,
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: textColor),
                          dropdownColor: cardBg,
                          style: AppTypography.sans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: 'all',
                              child: Text(
                                'Dhammaan Culimada & Saxaabada',
                                style: AppTypography.sans(fontSize: 12, color: textColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...wisdomProvider.availableSpeakers.map(
                              (speaker) => DropdownMenuItem<String>(
                                value: speaker,
                                child: Text(
                                  speaker,
                                  style: AppTypography.sans(fontSize: 12, color: textColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              wisdomProvider.setSpeaker(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 4. Main Content List
            Expanded(
              child: wisdomProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? _buildEmptyState(context, isDark, textColor, textSub, wisdomProvider)
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            // Show Featured Carousel Card if not filtering by favorites or search
                            if (!wisdomProvider.showOnlyFavorites &&
                                wisdomProvider.searchQuery.isEmpty &&
                                wisdomProvider.selectedCategory == 'all' &&
                                wisdomProvider.selectedSpeaker == 'all' &&
                                featuredWisdom != null)
                              WisdomCardWidget(
                                wisdom: featuredWisdom,
                                isFeatured: true,
                                onPrevious: wisdomProvider.previousWisdom,
                                onNext: wisdomProvider.nextWisdom,
                              ),

                            // Header for general feed
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      RubElHizbIcon(size: 14, color: accentColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        wisdomProvider.showOnlyFavorites
                                            ? 'Xikmadahaaga Kaydsan (${filteredList.length})'
                                            : 'Dhammaan Xikmadaha (${filteredList.length})',
                                        style: AppTypography.serif(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (wisdomProvider.selectedCategory != 'all' ||
                                      wisdomProvider.selectedSpeaker != 'all' ||
                                      wisdomProvider.showOnlyFavorites ||
                                      wisdomProvider.searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        wisdomProvider.setCategory('all');
                                        wisdomProvider.setSpeaker('all');
                                        wisdomProvider.setSearchQuery('');
                                        if (wisdomProvider.showOnlyFavorites) {
                                          wisdomProvider.toggleShowOnlyFavorites();
                                        }
                                        _searchController.clear();
                                      },
                                      child: Text(
                                        'Dib u celi',
                                        style: AppTypography.sans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // List of wisdom cards
                            ...filteredList.map(
                              (item) => WisdomCardWidget(wisdom: item),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color textSub,
    WisdomProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                provider.showOnlyFavorites
                    ? Icons.bookmark_border_rounded
                    : Icons.search_off_rounded,
                size: 36,
                color: AppTheme.accent(isDark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.showOnlyFavorites
                  ? 'Weli ma aadan kaydsan wax xikmad ah'
                  : 'Lama helin xikmad u dhiganta raadintaada',
              textAlign: TextAlign.center,
              style: AppTypography.serif(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.showOnlyFavorites
                  ? 'Taabo calaamadda buug-calaamadeynta (bookmark) ee xikmad kasta si aad halkan ugu aragto.'
                  : 'Fadlan hubi higgaadda ama isku day qayb kale.',
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 13,
                color: textSub,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent(isDark),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                provider.setCategory('all');
                provider.setSpeaker('all');
                provider.setSearchQuery('');
                if (provider.showOnlyFavorites) {
                  provider.toggleShowOnlyFavorites();
                }
                _searchController.clear();
              },
              child: const Text('Eeg Dhammaan Xikmadaha'),
            ),
          ],
        ),
      ),
    );
  }
}
