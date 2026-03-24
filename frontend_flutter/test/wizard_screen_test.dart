import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend_flutter/screens/wizard_screen.dart';
import 'package:frontend_flutter/screens/dashboard_screen.dart';
import 'package:frontend_flutter/core/enums/tier_level.dart';
import 'package:frontend_flutter/providers/user_data_provider.dart';

// Fake implementations for dart:io HttpClient to override global behavior
// without pulling in extra dependencies like mocktail or http_mock_adapter.

class FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return FakeHttpClientRequest();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  int contentLength = -1;

  @override
  bool persistentConnection = true;

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  void write(Object? object) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    // Consume the stream as if we are receiving the request body
    await stream.drain();
  }

  @override
  Future<HttpClientResponse> close() async {
    return FakeHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {
    'content-type': ['application/json; charset=utf-8']
  };

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  int get contentLength => -1;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  List<RedirectInfo> get redirects => [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Return mock JSON response matching what DashboardScreen expects:
    // {"freedomAge": 42, "targetNestEgg": 15000000.0}
    final responseBytes = utf8.encode('{"freedomAge": 42, "targetNestEgg": 15000000.0}');
    return Stream.value(responseBytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  Widget createWizardScreen(UserDataProvider provider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDataProvider>.value(value: provider),
      ],
      child: MaterialApp(
        home: const WizardScreen(tier: TierLevel.pro),
      ),
    );
  }

  testWidgets('WizardScreen completes flow and updates UserDataProvider then navigates to DashboardScreen and displays result', (WidgetTester tester) async {
    final provider = UserDataProvider();

    await tester.pumpWidget(createWizardScreen(provider));

    // Page 1: Ülkeniz neresi?
    expect(find.text('Ülkeniz neresi?'), findsOneWidget);
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    // Page 2: Yaşınız kaç?
    expect(find.text('Yaşınız kaç?'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Mevcut Yaşınız (örn. 35)'), '28');
    await tester.enterText(find.widgetWithText(TextFormField, 'Tahmini Vefat Yaşınız :('), '85');
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    // Page 3: Finansal Durumunuz
    expect(find.text('Finansal Durumunuz'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Aylık Net Geliriniz (TL)'), '60000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Aylık Gideriniz (TL)'), '35000');
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    // Page 4: Portföy Dağılımınız
    expect(find.text('Portföy Dağılımınız'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Toplam Birikim (TL)'), '150000');
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    // Page 5: Gelecek Hedefleri
    expect(find.text('Gelecek Hedefleri'), findsOneWidget);

    // Tap Sonuçları Gör to submit and navigate
    await tester.tap(find.text('Sonuçları Gör'));

    // Pump frames to complete navigation and future builder API call
    await tester.pumpAndSettle();

    // Verify Provider state has been updated
    expect(provider.currentAge, 28);
    expect(provider.deathAge, 85);
    expect(provider.monthlyIncome, 60000);
    expect(provider.monthlyExpense, 35000);
    expect(provider.totalSavings, 150000);

    // Verify Navigation to DashboardScreen
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Verify our Mocked API call response is displayed
    expect(find.text('Simülasyon Sonucu'), findsOneWidget);
    expect(find.text('42'), findsOneWidget); // freedomAge from our mock
  });
}
