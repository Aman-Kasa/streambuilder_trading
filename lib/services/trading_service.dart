/*
 * TRADING SERVICE - The "data factory"
 * 
 * This service creates and broadcasts all the fake trading data.
 * It's like a TV station that broadcasts on multiple channels.
 * 
 * KEY STREAMBUILDER CONCEPT:
 * - StreamController = TV channel
 * - Timer.periodic = TV schedule
 * - .add() = Broadcasting new show
 * - StreamBuilder = TV that auto-switches when new show starts
 */

import 'dart:async';
import 'dart:math';
import '../models/market_data.dart';

class TradingService {
  // ========== STREAM CONTROLLERS (TV Channels) ==========
  final StreamController<MarketData> _marketController = StreamController<MarketData>.broadcast();
  final StreamController<SystemHealth> _systemController = StreamController<SystemHealth>.broadcast();
  final StreamController<NewsAlert> _newsController = StreamController<NewsAlert>.broadcast();
  final StreamController<TradeExecution> _tradeController = StreamController<TradeExecution>.broadcast();

  // ========== PUBLIC STREAMS (What StreamBuilders listen to) ==========
  Stream<MarketData> get marketStream => _marketController.stream;
  Stream<SystemHealth> get systemStream => _systemController.stream;
  Stream<NewsAlert> get newsStream => _newsController.stream;
  Stream<TradeExecution> get tradeStream => _tradeController.stream;

  // ========== DATA STORAGE ==========
  final List<ChartPoint> _priceHistory = [];
  final List<NewsAlert> _recentNews = [];
  double _currentPrice = 150.25;
  double _portfolioValue = 125000.0;
  int _activeUsers = 1247;
  final Random _random = Random();

  // ========== TIMERS (TV Schedules) ==========
  Timer? _marketTimer;
  Timer? _newsTimer;
  Timer? _systemTimer;

  // ========== PUBLIC GETTERS ==========
  List<ChartPoint> get priceHistory => _priceHistory;
  List<NewsAlert> get recentNews => _recentNews;
  double get currentPrice => _currentPrice;
  double get portfolioValue => _portfolioValue;

  // ========== START DATA STREAMS ==========
  // This starts all the "TV schedules"
  void startStreams() {
    // MARKET DATA: Every 1.5 seconds (like real stock tickers)
    _marketTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _generateMarketData();
    });

    // NEWS ALERTS: Every 8 seconds (breaking news)
    _newsTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _generateNewsAlert();
    });

    // SYSTEM HEALTH: Every 3 seconds (server monitoring)
    _systemTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _generateSystemHealth();
    });
  }

  // ========== MARKET DATA GENERATOR ==========
  void _generateMarketData() {
    // Generate realistic price movement
    final change = (_random.nextDouble() - 0.5) * 3.0;
    _currentPrice = max(100, _currentPrice + change);
    _portfolioValue += (_random.nextDouble() - 0.5) * 2000;
    
    // Store for chart (keep last 50 points)
    _priceHistory.add(ChartPoint(_currentPrice, DateTime.now()));
    if (_priceHistory.length > 50) _priceHistory.removeAt(0);

    // 🔴 BROADCAST TO ALL STREAMBUILDERS!
    _marketController.add(MarketData(
      symbol: 'AAPL',
      price: _currentPrice,
      change: change,
      volume: 50000 + _random.nextInt(100000),
      marketCap: 2.8e12,
      pe: 28.5 + _random.nextDouble() * 2,
      timestamp: DateTime.now(),
    ));

    // Sometimes generate trade execution
    if (_random.nextBool()) {
      _tradeController.add(TradeExecution(
        orderId: 'ORD${_random.nextInt(99999)}',
        symbol: 'AAPL',
        side: _random.nextBool() ? 'BUY' : 'SELL',
        quantity: 100 + _random.nextInt(500),
        price: _currentPrice + (_random.nextDouble() - 0.5) * 0.5,
        status: 'FILLED',
        timestamp: DateTime.now(),
      ));
    }
  }

  // ========== NEWS GENERATOR ==========
  void _generateNewsAlert() {
    final headlines = [
      'Apple announces new AI chip breakthrough',
      'Market volatility increases amid tech earnings',
      'Federal Reserve hints at rate changes',
      'Apple stock reaches new resistance level',
      'Tech sector shows strong momentum',
      'Breaking: Apple partnership with major automaker',
    ];
    
    final alert = NewsAlert(
      headline: headlines[_random.nextInt(headlines.length)],
      impact: ['HIGH', 'MEDIUM', 'LOW'][_random.nextInt(3)],
      sentiment: _random.nextBool() ? 'POSITIVE' : 'NEGATIVE',
      timestamp: DateTime.now(),
    );
    
    _recentNews.insert(0, alert);
    if (_recentNews.length > 10) _recentNews.removeLast();
    
    // 🔴 BROADCAST TO ALL NEWS STREAMBUILDERS!
    _newsController.add(alert);
  }

  // ========== SYSTEM HEALTH GENERATOR ==========
  void _generateSystemHealth() {
    _activeUsers += _random.nextInt(20) - 10;
    _activeUsers = max(1000, _activeUsers);
    
    // 🔴 BROADCAST TO ALL SYSTEM STREAMBUILDERS!
    _systemController.add(SystemHealth(
      cpuUsage: 15 + _random.nextInt(25),
      memoryUsage: 45 + _random.nextInt(20),
      diskUsage: 60 + _random.nextInt(15),
      networkLatency: 12 + _random.nextInt(8),
      activeUsers: _activeUsers,
      ordersPerSecond: 850 + _random.nextInt(300),
      uptime: Duration(hours: 72, minutes: _random.nextInt(60)),
    ));
  }

  // ========== CLEANUP ==========
  void dispose() {
    _marketTimer?.cancel();
    _newsTimer?.cancel();
    _systemTimer?.cancel();
    _marketController.close();
    _systemController.close();
    _newsController.close();
    _tradeController.close();
  }
}