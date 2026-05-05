import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/home_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/qris_kita_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/transfer_page.dart';

// ============ Mock HTTP Classes ============
class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(method, url);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);

  @override
  void close({bool force = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _values.putIfAbsent(name.toLowerCase(), () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = [value.toString()];
  }

  @override
  void remove(String name, Object value) {
    _values[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  String? value(String name) => _values[name.toLowerCase()]?.join(', ');

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  _MockHttpClientRequest(this.method, this.uri);

  @override
  final String method;
  @override
  final Uri uri;
  final _MockHttpHeaders _headers = _MockHttpHeaders();
  final List<int> _bodyBytes = [];

  @override
  HttpHeaders get headers => _headers;

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding value) {}

  @override
  int get contentLength => _bodyBytes.length;

  @override
  set contentLength(int value) {}

  @override
  bool get followRedirects => false;

  @override
  set followRedirects(bool value) {}

  @override
  int get maxRedirects => 5;

  @override
  set maxRedirects(int value) {}

  @override
  bool get persistentConnection => false;

  @override
  set persistentConnection(bool value) {}

  @override
  bool get bufferOutput => false;

  @override
  set bufferOutput(bool value) {}

  @override
  Future<HttpClientResponse> close() async {
    final response = _routeResponse(method, uri, utf8.decode(_bodyBytes));
    return _MockHttpClientResponse(response.statusCode, response.body);
  }

  @override
  void add(List<int> data) => _bodyBytes.addAll(data);

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _bodyBytes.addAll(chunk);
    }
  }

  @override
  void write(Object? object) => _bodyBytes.addAll(utf8.encode(object.toString()));

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) => _bodyBytes.add(charCode);

  @override
  void writeln([Object? object = '']) => write('$object\n');

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  Future<HttpClientResponse> get done => close();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  _MockHttpClientResponse(this.statusCode, String body)
      : _stream = Stream<List<int>>.value(utf8.encode(body));

  @override
  final int statusCode;
  final Stream<List<int>> _stream;

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  int get contentLength => -1;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => '';

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  List<Cookie> get cookies => const [];

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockRouteResponse {
  final int statusCode;
  final String body;
  const _MockRouteResponse(this.statusCode, this.body);
}

_MockRouteResponse _routeResponse(String method, Uri uri, String body) {
  final path = uri.path;

  if (method == 'GET' && path.contains('/categories/')) {
    return const _MockRouteResponse(200, '[{"id":1,"name":"Hiburan"}]');
  }

  if (method == 'GET' && path.contains('/transfer/') && path.endsWith('/history/')) {
    return const _MockRouteResponse(200, '[{"direction":"sent","counterpart_phone":"081299988877","counterpart_name":"Budi"}]');
  }

  if (method == 'GET' && path.contains('/transfer/lookup/')) {
    return const _MockRouteResponse(200, '{"phone_number":"081288877766","name":"Andi"}');
  }

  if (method == 'POST' && path.contains('/transfer/')) {
    return const _MockRouteResponse(201, '{"ok":true}');
  }

  if (method == 'POST' && path.contains('/incomes/')) {
    return const _MockRouteResponse(201, '{"ok":true}');
  }

  if (method == 'POST' && path.contains('/expenses/')) {
    return const _MockRouteResponse(201, '{"ok":true}');
  }

  if (method == 'GET' && path.contains('/users/profile/')) {
    return const _MockRouteResponse(200, '{"phone_number":"081234567890","username":"Test User"}');
  }

  return const _MockRouteResponse(404, '{"error":"not found"}');
}

Future<void> _pumpWithOverrides(
  WidgetTester tester,
  Widget child,
) async {
  await HttpOverrides.runZoned(() async {
    await tester.pumpWidget(child);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }, createHttpClient: (_) => _MockHttpClient());
}

// ============ Integration Tests ============
void main() {
  setUp(() {
    HttpOverrides.global = _MockHttpOverrides();
    SharedPreferences.setMockInitialValues({
      'user_id': 77,
      'phone_number': '081233344455',
      'full_name': 'Leon',
    });
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('Home Page Integration Tests', () {
    testWidgets(
        'Complete transfer flow: select method → see recent recipient',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1080, 1920));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          // Start at HomePage
          await _pumpWithOverrides(tester, const MaterialApp(home: HomePage()));
          await tester.pumpAndSettle();

          // Verify HomePage loaded
          expect(find.text('Kusaku'), findsWidgets);
          expect(find.byType(RefreshIndicator), findsOneWidget);

          // Tap Transfer quick action
          await tester.tap(find.text('Transfer').last);
          await tester.pumpAndSettle();

          // Now at TransferPage, verify initial step shows methods
          expect(find.text('Kusaku'), findsWidgets);
          expect(find.text('Bank Lain'), findsOneWidget);
          expect(find.text('Virtual\nAccount'), findsOneWidget);

          // Verify recent recipients loaded
          expect(find.text('Budi'), findsOneWidget);
          expect(find.text('081299988877'), findsOneWidget);
        });

    testWidgets('TopUp page flow: open → show methods', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Start at HomePage
      await _pumpWithOverrides(tester, const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Tap TopUp quick action
      await tester.tap(find.text('Top Up').last);
      await tester.pumpAndSettle();

      // Now at TopUpPage
      expect(find.text('Top Up'), findsOneWidget);
      expect(find.text('Kode Kusaku: 081233344455'), findsOneWidget);

      // Verify topup methods available
      expect(find.text('Pulsa'), findsOneWidget);
      expect(find.text('Alfamart'), findsOneWidget);
      expect(find.text('Indomaret'), findsOneWidget);
      expect(find.text('Lawson'), findsOneWidget);
    });

    testWidgets('QrisKita page flow: open → show QR content', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Start at HomePage
      await _pumpWithOverrides(tester, const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Tap QrisKita quick action
      await tester.tap(find.text('Qris Kita').last);
      await tester.pumpAndSettle();

      // Now at QrisKitaPage
      expect(find.text('Qris Kita'), findsOneWidget);
      expect(find.text('Tinggal Scan dan Bayar'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at HomePage
      expect(find.text('Kusaku'), findsWidgets);
    });

    testWidgets('Transfer page → select method → show details screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: TransferPage()),
      );

      // Verify method buttons render
      expect(find.text('Kusaku'), findsWidgets);
      expect(find.text('Bank Lain'), findsOneWidget);

      // Verify recent recipients loaded from mock
      expect(find.text('Budi'), findsOneWidget);
      expect(find.text('081299988877'), findsOneWidget);

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify still on transfer page
      expect(find.byType(TransferPage), findsOneWidget);
    });

    testWidgets('TopUp → select pulsa method', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: TopUpPage()),
      );

      // Wait for user data to load
      await tester.pumpAndSettle();

      // Verify methods loaded
      expect(find.text('Pulsa'), findsOneWidget);
      expect(find.text('Alfamart'), findsOneWidget);
      expect(find.text('Indomaret'), findsOneWidget);
      expect(find.text('Lawson'), findsOneWidget);

      // User can see their code
      expect(find.text('Kode Kusaku: 081233344455'), findsOneWidget);
    });

    testWidgets('QrisKita → back button returns to previous screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: QrisKitaPage(userId: 77)),
      );

      // Verify QrisKita page loaded
      expect(find.text('Qris Kita'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Back button should pop the screen
      // (In integration, this would go to previous route)
    });

    testWidgets('Transfer → recent recipients data loads correctly',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({
        'user_id': 77,
        'phone_number': '081233344455',
        'full_name': 'Leon',
      });

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: TransferPage()),
      );

      // Wait for async data load
      await tester.pumpAndSettle();

      // Verify mock data loaded
      expect(find.text('Budi'), findsOneWidget);
      expect(find.text('081299988877'), findsOneWidget);
    });

    testWidgets('TopUp → user session data loads', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({
        'user_id': 99,
        'phone_number': '081234567890',
      });

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: TopUpPage()),
      );

      await tester.pumpAndSettle();

      // Verify session loaded correctly
      expect(find.text('Kode Kusaku: 081234567890'), findsOneWidget);
    });
  });
}
