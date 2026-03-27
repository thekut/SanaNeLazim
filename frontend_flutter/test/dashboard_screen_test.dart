import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:frontend_flutter/screens/dashboard_screen.dart';
import 'package:frontend_flutter/providers/user_data_provider.dart';
import 'package:frontend_flutter/core/enums/tier_level.dart';
import 'dart:async';

import 'dashboard_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  testWidgets('DashboardScreen shows error when backend connection fails', (WidgetTester tester) async {
    final mockClient = MockClient();

    // Setup the mock to return a 500 error after a short delay
    // This allows the initial loading state to render
    when(mockClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return http.Response('Internal Server Error', 500);
    });

    // Create the test widget tree
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserDataProvider(),
        child: MaterialApp(
          home: DashboardScreen(
            tier: TierLevel.basic,
            httpClient: mockClient,
          ),
        ),
      ),
    );

    // Initial state should be loading. Note: _calculationFuture is set in addPostFrameCallback.
    // So we need to pump once for the frame callback to run and state to update to loading.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Python Motoru Hesaplarken Lütfen Bekleyin...'), findsOneWidget);

    // Wait for the future to complete
    await tester.pumpAndSettle();

    // Verify the error message is displayed
    expect(find.textContaining('Sunucu Kapalı veya Hata:'), findsOneWidget);
    expect(find.textContaining('Exception: Backend bağlantı hatası: 500'), findsOneWidget);
  });
}
