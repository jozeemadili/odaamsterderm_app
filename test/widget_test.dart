import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:odaamsterderm_app/app/app.dart';

void main() {
  // flutter_secure_storage talks to the platform over a MethodChannel that
  // has no real implementation in the widget-test VM — without a mock
  // handler its calls never resolve, which stalls the app on the splash
  // screen forever. Standing in for "no token stored" here mirrors a real
  // first-launch device.
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async => null);

  testWidgets('Signed-out users land on the public marketplace', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: OdaamsterdermApp()));
    await tester.pumpAndSettle();

    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Set your location'), findsOneWidget);

    // Sellers and customers sign in from the marketplace header.
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'odaamsterderm'
        'hub',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Sign in to your account'), findsOneWidget);
  });
}
