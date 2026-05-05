import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/keuntungan_kusaku_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/kusaku_points_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/kusaku_stamp_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/profile_page.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest('GET', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async => _MockHttpClientRequest('POST', url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(method, url);
  }

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

  final String method;
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
    final response = _routeResponse(method, uri);
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
  void writeAll(Iterable objects, [String separator = '']) => write(objects.join(separator));

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

_MockRouteResponse _routeResponse(String method, Uri uri) {
  final path = uri.path;

  if (method == 'GET' && path.contains('/users/profile/')) {
    return const _MockRouteResponse(200, '{"username":"Leon","phone_number":"081233344455"}');
  }

  if (method == 'GET' && path.contains('/balance/')) {
    return const _MockRouteResponse(200, '{"kusaku_points":1200}');
  }

  if (method == 'GET' && path.contains('/expenses/')) {
    return const _MockRouteResponse(200, '[{"kusaku_points":100,"receiver":"Warung","date":"2025-05-15T10:00:00"},{"kusaku_points":250,"receiver":"Resto","date":"2025-05-16T10:00:00"}]');
  }

  if (method == 'GET' && path.contains('/stamp/history/')) {
    return const _MockRouteResponse(200, '[{"redeemed_at":"2025-05-20T10:00:00","points_used":300,"stamp":{"title":"Makan Gratis"}}]');
  }

  if (method == 'GET' && path.contains('/stamp/view/')) {
    return const _MockRouteResponse(200, '[{"id":1,"image":"/stamp/1.png","title":"Stamp Aktif A","points_needed":500,"deadline":"2025-12-31T23:59:59","reward_label":"Voucher 50K","is_expired":false},{"id":2,"image":"/stamp/2.png","title":"Stamp Nonaktif B","points_needed":700,"deadline":"2025-11-30T23:59:59","reward_label":"Voucher 100K","is_expired":true}]');
  }

  return const _MockRouteResponse(404, '{"error":"not found"}');
}

Future<void> _pumpWithOverrides(WidgetTester tester, Widget child) async {
  await HttpOverrides.runZoned(() async {
    await tester.pumpWidget(child);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }, createHttpClient: (_) => _MockHttpClient());
}

void main() {
  setUp(() {
    HttpOverrides.global = _MockHttpOverrides();
    SharedPreferences.setMockInitialValues({
      'user_id': 77,
      'phone_number': '081233344455',
      'full_name': 'Leon',
      'fingerprint_enabled': false,
    });
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('Keuntungan Kusaku', () {
    testWidgets('shows all keuntungan cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: KeuntunganKusakuPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Keuntungan Pakai Kusaku'), findsOneWidget);
      expect(find.text('Atur Keuangan dengan Mudah'), findsOneWidget);
      expect(find.text('Pencatatan Keuangan Otomatis'), findsOneWidget);
      expect(find.text('Keamanan Lebih terjamin'), findsOneWidget);
      expect(find.text('Nikmati layanan keuangan dari A.I Kusaku "SI PINTAR"'), findsOneWidget);
      expect(find.textContaining('tanpa perlu mencatat keuangan'), findsOneWidget);
      expect(find.text('Data pribadi dan saldo akan terjaga keamanannya'), findsOneWidget);
    });
  });

  group('Kusaku Points', () {
    testWidgets('shows summary and transaction lists', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: KusakuPointsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kusaku Point'), findsOneWidget);
      expect(find.text('1200'), findsOneWidget);
      expect(find.text('Setara dengan Rp 1200'), findsOneWidget);
      expect(find.text('Didapat'), findsOneWidget);
      expect(find.text('Terpakai'), findsOneWidget);
      expect(find.text('Warung'), findsOneWidget);
      expect(find.text('Resto'), findsOneWidget);
      expect(find.text('+100 Points'), findsOneWidget);
      expect(find.text('+250 Points'), findsOneWidget);

      await tester.tap(find.text('Terpakai'));
      await tester.pumpAndSettle();

      expect(find.text('Kusaku Stamp Makan Gratis'), findsOneWidget);
      expect(find.text('-300 Points'), findsOneWidget);
    });
  });

  group('Kusaku Stamp', () {
    testWidgets('shows active and inactive stamps', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpWithOverrides(
        tester,
        const MaterialApp(home: KusakuStampPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kusaku Stamp'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Tidak aktif'), findsOneWidget);
      expect(find.text('Stamp Aktif A'), findsOneWidget);
      expect(find.text('Voucher 50K'), findsOneWidget);
      expect(find.text('Tukar Sekarang'), findsOneWidget);

      await tester.tap(find.text('Tidak aktif'));
      await tester.pumpAndSettle();

      expect(find.text('Stamp Nonaktif B'), findsOneWidget);
      expect(find.text('Voucher 100K'), findsOneWidget);
      expect(find.text('KADALUARSA'), findsOneWidget);
      expect(find.text('Tukar Sekarang'), findsNothing);
      expect(find.text('Poin Tidak Cukup'), findsNothing);
    });
  });
}
