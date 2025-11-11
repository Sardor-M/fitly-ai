// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitly_ai/main.dart';
import 'package:fitly_ai/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'public-anon-key',
    );
  });

  testWidgets('Splash screen shows brand name', (tester) async {
    await tester.pumpWidget(const StyleAIApp());
    await tester.pump();

    expect(find.text(AppConstants.appName.toUpperCase()), findsOneWidget);
  });
}
