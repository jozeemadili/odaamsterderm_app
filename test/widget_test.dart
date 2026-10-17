import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:odaamsterderm_app/app/app.dart';

void main() {
  // flutter_secure_storage talks to the platform over a MethodChannel that
  // has no real implementation in the widget-test VM — without a mock
  // handler its calls never resolve, which stalls the app on the splash
  // screen forever. Standing in for "no token stored" here mirrors a real
  // first-launch device.
  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    secureStorageChannel,
    (call) async => null,
  );

  testWidgets('App boots to the login screen when signed out', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OdaamsterdermApp()));
    await tester.pumpAndSettle();

    expect(find.text('odaamsterderm' 'hub', findRichText: true), findsOneWidget);
    expect(find.text('Sign in to your shop'), findsOneWidget);
  });
}
