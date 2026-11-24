import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'constants/app_colors.dart';
import 'services/storage_service.dart';
import 'services/app_audio_handler.dart';
import 'providers/audio_player_provider.dart';
import 'providers/adhkar_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tasbeeh_provider.dart';
import 'providers/wisdom_provider.dart';
import 'data/sample_data.dart';
import 'services/font_service.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'screens/app_splash_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force edge-to-edge system UI mode for Android 15/16 and modern devices
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  } catch (e) {
    debugPrint('SystemChrome edge-to-edge configuration error: $e');
  }

  StorageService storageService;
  try {
    storageService = await StorageService.getInstance();
  } catch (e) {
    debugPrint('StorageService init error: $e');
    storageService = StorageService.fallback();
  }

  try {
    await SampleData.loadLecturesFromAsset();
  } catch (e) {
    debugPrint('SampleData.loadLecturesFromAsset error: $e');
  }

  // Preload and initialize all Arabic, Somali, and Latin typography assets
  // before rendering the first frame to guarantee zero tofu (□) characters.
  try {
    await FontService.initialize();
  } catch (e) {
    debugPrint('FontService.initialize error: $e');
  }

  // Initialize Google Mobile Ads SDK (AdMob)
  try {
    await AdService().initialize();
  } catch (e) {
    debugPrint('AdService initialization error: $e');
  }

  // Initialize NotificationService for Daily Morning and Evening Adhkar reminders
  try {
    await NotificationService.instance.initialize(navigatorKey: appNavigatorKey);
  } catch (e) {
    debugPrint('NotificationService initialization error: $e');
  }

  // Initialize native Android Media3 / MediaSession AudioService
  AppAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => AppAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.sheekhxuseen.app.audio',
        androidNotificationChannelName: 'Codka Sheekh Xuseen Cali Jabuuti',
        androidNotificationChannelDescription:
            'Xakamaynta codadka muxaadarooyinka, qur\'aanka iyo adkaarta',
        androidNotificationIcon: 'drawable/ic_notification',
        androidShowNotificationBadge: true,
        androidStopForegroundOnPause: true,
        notificationColor: AppColors.primary,
      ),
    );
  } catch (e) {
    debugPrint('AudioService.init fallback: $e');
    audioHandler = AppAudioHandler(isFallback: true);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioPlayerProvider(storageService, audioHandler: audioHandler),
        ),
        ChangeNotifierProvider(
          create: (_) => AdhkarProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TasbeehProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => WisdomProvider(),
        ),
      ],
      child: const SheekhXuseenApp(),
    ),
  );
}

class SheekhXuseenApp extends StatelessWidget {
  const SheekhXuseenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Sheekh Xuseen Cali Jabuuti',
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: AppTheme.lightThemeData,
        darkTheme: AppTheme.darkThemeData,
        home: const AppSplashScreen(),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final bool isDesktopView = media.size.width > 500;
          final double targetWidth = isDesktopView ? 430.0 : media.size.width;

          if (!isDesktopView) {
            return child!;
          }

          return Container(
            color: const Color(0xFF0F172A),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 430),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipRect(
                  child: MediaQuery(
                    data: media.copyWith(
                      size: Size(targetWidth, media.size.height),
                    ),
                    child: child!,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
