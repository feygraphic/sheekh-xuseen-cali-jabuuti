import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/main_shell.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/tasbeeh_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(StorageService storage) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider(storage)),
        ChangeNotifierProvider(create: (_) => AdhkarProvider(storage)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storage)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
        ChangeNotifierProvider(create: (_) => TasbeehProvider(storage)),
      ],
      child: const MaterialApp(
        home: MainShell(),
      ),
    );
  }

  testWidgets('Navigation: Quick Services (Duruus, Qur\'aan, Adkaar, Ramadan, Tasbiix) with Back Arrow & Android Back', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('ListTile background color or ink splashes') ||
          msg.contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    final storage = await StorageService.getInstance();

    await tester.pumpWidget(buildApp(storage));
    await tester.pumpAndSettle();

    // 1. Verify Home is initially loaded
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 1: Duruus Quick Service ---
    await tester.tap(find.text('Duruus'));
    await tester.pumpAndSettle();
    expect(find.text('Muxaadarooyinka'), findsOneWidget);
    // Back arrow is present
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Tap Back arrow
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    // Returned to Home
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 2: Qur'aan Quick Service ---
    await tester.tap(find.text('Qur\'aan').first);
    await tester.pumpAndSettle();
    expect(find.text('Qur\'aanka Kariimka'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Tap Back arrow
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 3: Adkaar Quick Service ---
    await tester.tap(find.text('Adkaar').first);
    await tester.pumpAndSettle();
    expect(find.text('Qaybaha Adkaarta'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Tap Back arrow
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 4: Ramadaan Quick Service ---
    await tester.tap(find.text('Ramadaan'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Tap Back arrow
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 5: Tasbiix Standalone Screen ---
    await tester.tap(find.text('Tasbiix'));
    await tester.pumpAndSettle();
    expect(find.byType(TasbeehScreen), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    // Tap Back arrow
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TasbeehScreen), findsNothing);
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 6: Android System Back Navigation ---
    // Open Qur'aan
    await tester.tap(find.text('Qur\'aan').first);
    await tester.pumpAndSettle();
    expect(find.text('Qur\'aanka Kariimka'), findsOneWidget);
    // Simulate Android system back button while on another tab
    final bool didPop = await tester.binding.handlePopRoute();
    expect(didPop, true);
    await tester.pumpAndSettle();
    // Successfully returned to Home without showing exit confirmation dialog!
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);
    expect(find.text('Do you want to exit?'), findsNothing);

    // --- TEST 7: Exit Confirmation Dialog on Home ---
    // User is on main Home screen and presses Android back button
    final bool popOnHome = await tester.binding.handlePopRoute();
    expect(popOnHome, true);
    await tester.pumpAndSettle();

    // Verify Exit Confirmation Dialog is shown with exact required text
    expect(find.text('Do you want to exit?'), findsOneWidget);
    expect(find.text('Are you sure you want to exit Sheikh Xuseen Cali Jabuuti?'), findsOneWidget);
    expect(find.text('STAY'), findsOneWidget);
    expect(find.text('YES'), findsOneWidget);

    // Tap STAY -> dialog dismisses, app remains on Home
    await tester.tap(find.text('STAY'));
    await tester.pumpAndSettle();

    expect(find.text('Do you want to exit?'), findsNothing);
    expect(find.text('KUSOO DHOWOW'), findsOneWidget);

    // --- TEST 8: Exit Confirmation Dialog YES Button ---
    bool systemPopCalled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == 'SystemNavigator.pop') {
        systemPopCalled = true;
      }
      return null;
    });

    // Press Android back button on Home again
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Do you want to exit?'), findsOneWidget);
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();

    expect(systemPopCalled, isTrue, reason: 'Tapping YES must invoke SystemNavigator.pop');
  });
}
