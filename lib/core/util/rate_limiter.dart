// Rate limiter for OpenFoodFacts API compliance
// According to https://openfoodfacts.github.io/openfoodfacts-server/api/:
// - 10 req/min for search queries
// - 100 req/min for product queries

import 'dart:async';

class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final List<DateTime> _requestTimes = [];

  RateLimiter({
    required this.maxRequests,
    required this.timeWindow,
  });

  /// Factory pour créer un rate limiter pour les recherches OFF (10 req/min)
  factory RateLimiter.forSearch() {
    return RateLimiter(
      maxRequests: 10,
      timeWindow: const Duration(minutes: 1),
    );
  }

  /// Factory pour créer un rate limiter pour les produits OFF (100 req/min)
  factory RateLimiter.forProduct() {
    return RateLimiter(
      maxRequests: 100,
      timeWindow: const Duration(minutes: 1),
    );
  }

  /// Vérifie si une requête peut être effectuée
  bool canMakeRequest() {
    _cleanOldRequests();
    return _requestTimes.length < maxRequests;
  }

  /// Enregistre une nouvelle requête
  void recordRequest() {
    _cleanOldRequests();
    _requestTimes.add(DateTime.now());
  }

  /// Attend jusqu'à ce qu'une requête puisse être effectuée
  Future<void> waitForAvailability() async {
    while (!canMakeRequest()) {
      _cleanOldRequests();
      if (_requestTimes.isNotEmpty) {
        final oldestRequest = _requestTimes.first;
        final waitTime = timeWindow - DateTime.now().difference(oldestRequest);
        if (waitTime.inMilliseconds > 0) {
          await Future.delayed(waitTime);
        }
      }
    }
  }

  /// Exécute une requête en respectant les limites de taux
  Future<T> execute<T>(Future<T> Function() request) async {
    await waitForAvailability();
    recordRequest();
    return request();
  }

  /// Nettoie les requêtes anciennes
  void _cleanOldRequests() {
    final cutoff = DateTime.now().subtract(timeWindow);
    _requestTimes.removeWhere((time) => time.isBefore(cutoff));
  }

  /// Retourne le nombre de requêtes restantes
  int get remainingRequests {
    _cleanOldRequests();
    return maxRequests - _requestTimes.length;
  }

  /// Retourne le temps d'attente avant la prochaine requête disponible
  Duration get timeUntilNextRequest {
    _cleanOldRequests();
    if (_requestTimes.length < maxRequests) {
      return Duration.zero;
    }
    final oldestRequest = _requestTimes.first;
    return timeWindow - DateTime.now().difference(oldestRequest);
  }
}

