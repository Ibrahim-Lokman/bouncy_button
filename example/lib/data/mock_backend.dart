import 'dart:collection';
import 'dart:math';

import '../state/demo_settings.dart';
import 'fixtures.dart';
import 'models.dart';

/// Why a mock request failed.
enum MockFailure {
  network('No connection. Check your network and try again.'),
  server('The server had a problem. Please try again.');

  const MockFailure(this.message);

  /// A message suitable for showing to the user.
  final String message;
}

/// The error thrown by [MockBackend] requests.
class MockApiException implements Exception {
  const MockApiException(this.failure);

  final MockFailure failure;

  String get message => failure.message;

  @override
  String toString() => 'MockApiException(${failure.name})';
}

/// An in-memory stand-in for a real API. It makes no network requests.
///
/// Latency, failure rate, and offline mode come from [settings]. Random
/// failures use a seeded generator, so a run can be repeated, and tests can
/// force exact outcomes with [script].
class MockBackend {
  MockBackend({required this.settings, int seed = 42}) : _random = Random(seed);

  final DemoSettings settings;
  final Random _random;
  final Queue<MockFailure?> _script = Queue<MockFailure?>();
  final Set<String> _favorites = {'keyboard'};

  /// The IDs of favorited products.
  Set<String> get favorites => Set.unmodifiable(_favorites);

  /// Forces the outcomes of the next requests, in order.
  ///
  /// A null entry succeeds. Scripted outcomes take priority over
  /// [DemoSettings.failureRate], but offline mode still fails first.
  void script(Iterable<MockFailure?> outcomes) => _script.addAll(outcomes);

  /// Restores favorites and removes scripted outcomes.
  void reset() {
    _script.clear();
    _favorites
      ..clear()
      ..add('keyboard');
  }

  /// Returns the catalog, or nothing if the catalog is set to be empty.
  Future<List<Product>> fetchProducts() async {
    await _request();
    return settings.emptyCatalog ? const [] : mockProducts;
  }

  /// Saves a favorite. The change is kept only if the request succeeds.
  Future<void> setFavorite(String productId, {required bool favorite}) async {
    await _request();
    if (favorite) {
      _favorites.add(productId);
    } else {
      _favorites.remove(productId);
    }
  }

  Future<void> _request() async {
    await Future<void>.delayed(settings.latency);
    if (settings.offline) {
      throw const MockApiException(MockFailure.network);
    }
    if (_script.isNotEmpty) {
      final outcome = _script.removeFirst();
      if (outcome != null) {
        throw MockApiException(outcome);
      }
      return;
    }
    if (_random.nextDouble() < settings.failureRate) {
      throw const MockApiException(MockFailure.server);
    }
  }
}
