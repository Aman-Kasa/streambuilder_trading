import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const StreamBuilderApp());
}

class StreamBuilderApp extends StatelessWidget {
  const StreamBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamBuilder Pro - Trading Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const TradingPlatform(),
    );
  }
}

class TradingPlatform extends StatefulWidget {
  const TradingPlatform({super.key});

  @override
  State<TradingPlatform> createState() => _TradingPlatformState();
}

class _TradingPlatformState extends State<TradingPlatform>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late StreamController<MarketData> _marketController;
  late StreamController<SystemHealth> _systemController;
  late StreamController<NewsAlert> _newsController;
  late StreamController<TradeExecution> _tradeController;
  late Timer _marketTimer;
  late Timer _newsTimer;
  
  final List<ChartPoint> _priceHistory = [];
  final List<NewsAlert> _recentNews = [];
  double _currentPrice = 150.25;
  double _portfolioValue = 125000.0;
  int _activeUsers = 1247;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _marketController = StreamController<MarketData>.broadcast();
    _systemController = StreamController<SystemHealth>.broadcast();
    _newsController = StreamController<NewsAlert>.broadcast();
    _tradeController = StreamController<TradeExecution>.broadcast();
    
    _startDataStreams();
  }

  void _startDataStreams() {
    _marketTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) _simulateMarketData();
    });

    _newsTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) _simulateNewsAlert();
    });

    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) _simulateSystemHealth();
    });
  }

  void _simulateMarketData() {
    final change = (_random.nextDouble() - 0.5) * 3.0;
    _currentPrice = max(100, _currentPrice + change);
    _portfolioValue += (_random.nextDouble() - 0.5) * 2000;
    
    _priceHistory.add(ChartPoint(_currentPrice, DateTime.now()));
    if (_priceHistory.length > 50) _priceHistory.removeAt(0);

    _marketController.add(MarketData(
      symbol: 'AAPL',
      price: _currentPrice,
      change: change,
      volume: 50000 + _random.nextInt(100000),
      marketCap: 2.8e12,
      pe: 28.5 + _random.nextDouble() * 2,
      timestamp: DateTime.now(),
    ));

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

  void _simulateNewsAlert() {
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
    _newsController.add(alert);
  }

  void _simulateSystemHealth() {
    _activeUsers += _random.nextInt(20) - 10;
    _activeUsers = max(1000, _activeUsers);
    
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

  @override
  void dispose() {
    _marketTimer.cancel();
    _newsTimer.cancel();
    _tabController.dispose();
    _marketController.close();
    _systemController.close();
    _newsController.close();
    _tradeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StreamBuilder Pro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Real-time Trading Platform',
                  style: TextStyle(fontSize: 12, color: Color(0xFF00D4FF)),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D4FF),
          labelColor: const Color(0xFF00D4FF),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Dashboard'),
            Tab(icon: Icon(Icons.show_chart, size: 20), text: 'Charts'),
            Tab(icon: Icon(Icons.account_balance_wallet, size: 20), text: 'Portfolio'),
            Tab(icon: Icon(Icons.newspaper, size: 20), text: 'News'),
            Tab(icon: Icon(Icons.monitor_heart, size: 20), text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildChartsView(),
          _buildPortfolioView(),
          _buildNewsView(),
          _buildSystemView(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMarketOverview(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildQuickStats()),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentTrades()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPriceChart(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildVolumeChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildTechnicalIndicators()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPortfolioValue(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAssetAllocation()),
              const SizedBox(width: 16),
              Expanded(child: _buildPerformanceMetrics()),
            ],
          ),
          const SizedBox(height: 16),
          _buildHoldings(),
        ],
      ),
    );
  }

  Widget _buildNewsView() {
    return Column(
      children: [
        _buildNewsHeader(),
        Expanded(child: _buildNewsFeed()),
      ],
    );
  }

  Widget _buildSystemView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSystemOverview(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildResourceUsage()),
              const SizedBox(width: 16),
              Expanded(child: _buildNetworkStats()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOverview() {
    return StreamBuilder<MarketData>(
      stream: _marketController.stream,
      initialData: MarketData(
        symbol: 'AAPL',
        price: 150.25,
        change: 0,
        volume: 75000,
        marketCap: 2.8e12,
        pe: 28.5,
        timestamp: DateTime.now(),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data!;
        final isPositive = data.change >= 0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E293B).withOpacity(0.9),
                const Color(0xFF334155).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPositive ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.symbol} • Apple Inc.',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'NASDAQ • Real-time',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${data.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}\$${data.change.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${((data.change / data.price) * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Volume', '${(data.volume / 1000).toStringAsFixed(0)}K'),
                  _buildStatItem('Market Cap', '\$${(data.marketCap / 1e12).toStringAsFixed(1)}T'),
                  _buildStatItem('P/E Ratio', data.pe.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AAPL PRICE CHART',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Last 50 Updates',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<MarketData>(
              stream: _marketController.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: ChartPainter(_priceHistory),
                  size: Size.infinite,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time →',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                '↑ Price (\$)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsFeed() {
    return StreamBuilder<NewsAlert>(
      stream: _newsController.stream,
      builder: (context, snapshot) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _recentNews.length,
          itemBuilder: (context, index) {
            final news = _recentNews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getImpactColor(news.impact).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getImpactColor(news.impact).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          news.impact,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _getImpactColor(news.impact),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        news.sentiment == 'POSITIVE' ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: news.sentiment == 'POSITIVE' ? Colors.green : Colors.red,
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(news.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.headline,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSystemOverview() {
    return StreamBuilder<SystemHealth>(
      stream: _systemController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final health = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E293B).withOpacity(0.9),
                const Color(0xFF334155).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text(
                'SYSTEM HEALTH',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthMetric('Active Users', '${health.activeUsers}', Icons.people),
                  _buildHealthMetric('Orders/sec', '${health.ordersPerSecond}', Icons.speed),
                  _buildHealthMetric('Uptime', '${health.uptime.inHours}h', Icons.timer),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK STATS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Day High', '\$152.45', Colors.green),
          _buildStatRow('Day Low', '\$148.12', Colors.red),
          _buildStatRow('52W High', '\$198.23', Colors.blue),
          _buildStatRow('52W Low', '\$124.17', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildRecentTrades() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT TRADES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<TradeExecution>(
            stream: _tradeController.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text(
                  'Waiting for trades...',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                );
              }
              
              final trade = snapshot.data!;
              return Column(
                children: [
                  _buildTradeRow(trade.side, trade.quantity, trade.price, trade.timestamp),
                  const SizedBox(height: 8),
                  Text(
                    'Order ID: ${trade.orderId}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRADING VOLUME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Shares (K)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<MarketData>(
              stream: _marketController.stream,
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(8, (index) {
                    final volume = 50 + _random.nextInt(150);
                    final height = (volume / 200) * 100;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color(0xFF0066FF),
                                Color(0xFF00D4FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${volume}K',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Time Periods →',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicators() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TECHNICAL INDICATORS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<MarketData>(
            stream: _marketController.stream,
            builder: (context, snapshot) {
              return Column(
                children: [
                  _buildIndicatorRow('RSI', '${45 + _random.nextInt(20)}', Colors.purple),
                  _buildIndicatorRow('MACD', '${(_random.nextDouble() - 0.5).toStringAsFixed(2)}', Colors.orange),
                  _buildIndicatorRow('SMA(20)', '\$${(_currentPrice - 2 + _random.nextDouble() * 4).toStringAsFixed(2)}', Colors.blue),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValue() {
    return StreamBuilder<MarketData>(
      stream: _marketController.stream,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E293B).withOpacity(0.9),
                const Color(0xFF334155).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text(
                'PORTFOLIO VALUE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '\$${_portfolioValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+\$${(_portfolioValue - 125000).toStringAsFixed(2)} (+${(((_portfolioValue - 125000) / 125000) * 100).toStringAsFixed(2)}%)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _portfolioValue > 125000 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssetAllocation() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ASSET ALLOCATION',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: PieChartPainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERFORMANCE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('1D Return', '+2.34%', Colors.green),
          _buildMetricRow('1W Return', '+5.67%', Colors.green),
          _buildMetricRow('1M Return', '-1.23%', Colors.red),
          _buildMetricRow('YTD Return', '+12.45%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildHoldings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT HOLDINGS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildHoldingRow('AAPL', 'Apple Inc.', 100, _currentPrice),
          _buildHoldingRow('MSFT', 'Microsoft Corp.', 50, 420.50),
          _buildHoldingRow('GOOGL', 'Alphabet Inc.', 25, 2850.75),
        ],
      ),
    );
  }

  Widget _buildNewsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0066FF).withOpacity(0.2),
            const Color(0xFF00D4FF).withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.newspaper, color: Color(0xFF00D4FF), size: 24),
          const SizedBox(width: 12),
          const Text(
            'Market News & Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          StreamBuilder<NewsAlert>(
            stream: _newsController.stream,
            builder: (context, snapshot) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceUsage() {
    return StreamBuilder<SystemHealth>(
      stream: _systemController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final health = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RESOURCE USAGE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              _buildResourceBar('CPU', health.cpuUsage, Colors.blue),
              const SizedBox(height: 12),
              _buildResourceBar('Memory', health.memoryUsage, Colors.purple),
              const SizedBox(height: 12),
              _buildResourceBar('Disk', health.diskUsage, Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkStats() {
    return StreamBuilder<SystemHealth>(
      stream: _systemController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final health = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERFORMANCE METRICS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Response Time', '${health.networkLatency}ms', Colors.green),
              _buildStatRow('Trades/Second', '${health.ordersPerSecond}', Colors.blue),
              _buildStatRow('Active Traders', '${health.activeUsers}', Colors.purple),
            ],
          ),
        );
      },
    );
  }

  // Helper widgets
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeRow(String side, int quantity, double price, DateTime time) {
    final isBuy = side == 'BUY';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          side,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isBuy ? Colors.green : Colors.red,
          ),
        ),
        Text(
          '$quantity @ \$${price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHealthMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00D4FF), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(String symbol, String name, int shares, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                symbol.substring(0, 2),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$shares shares',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                '\$${(shares * price).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'HIGH': return Colors.red;
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

// Data Models
class MarketData {
  final String symbol;
  final double price;
  final double change;
  final int volume;
  final double marketCap;
  final double pe;
  final DateTime timestamp;

  MarketData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.volume,
    required this.marketCap,
    required this.pe,
    required this.timestamp,
  });
}

class SystemHealth {
  final int cpuUsage;
  final int memoryUsage;
  final int diskUsage;
  final int networkLatency;
  final int activeUsers;
  final int ordersPerSecond;
  final Duration uptime;

  SystemHealth({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkLatency,
    required this.activeUsers,
    required this.ordersPerSecond,
    required this.uptime,
  });
}

class NewsAlert {
  final String headline;
  final String impact;
  final String sentiment;
  final DateTime timestamp;

  NewsAlert({
    required this.headline,
    required this.impact,
    required this.sentiment,
    required this.timestamp,
  });
}

class TradeExecution {
  final String orderId;
  final String symbol;
  final String side;
  final int quantity;
  final double price;
  final String status;
  final DateTime timestamp;

  TradeExecution({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.status,
    required this.timestamp,
  });
}

class ChartPoint {
  final double price;
  final DateTime time;

  ChartPoint(this.price, this.time);
}

// Custom Painters
class ChartPainter extends CustomPainter {
  final List<ChartPoint> points;

  ChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Horizontal grid lines (price levels)
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines (time)
    for (int i = 0; i <= 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw price line
    final linePaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final minPrice = points.isNotEmpty ? points.map((p) => p.price).reduce(min) : 0;
    final maxPrice = points.isNotEmpty ? points.map((p) => p.price).reduce(max) : 1;
    final priceRange = maxPrice - minPrice;
    
    for (int i = 0; i < points.length; i++) {
      final x = (i / max(1, points.length - 1)) * size.width;
      final normalizedPrice = priceRange > 0 ? (points[i].price - minPrice) / priceRange : 0.5;
      final y = size.height - (normalizedPrice * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw price points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x = (i / max(1, points.length - 1)) * size.width;
      final normalizedPrice = priceRange > 0 ? (points[i].price - minPrice) / priceRange : 0.5;
      final y = size.height - (normalizedPrice * size.height);
      canvas.drawCircle(Offset(x, y), 2, pointPaint);
    }

    // Draw price labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Y-axis labels (prices)
    for (int i = 0; i <= 4; i++) {
      final price = minPrice + (priceRange * (4 - i) / 4);
      final y = (i / 4) * size.height;
      
      textPainter.text = TextSpan(
        text: '\$${price.toStringAsFixed(1)}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-5, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;

    final segments = [
      {'value': 0.4, 'color': const Color(0xFF0066FF)},
      {'value': 0.3, 'color': const Color(0xFF00D4FF)},
      {'value': 0.2, 'color': const Color(0xFF7C3AED)},
      {'value': 0.1, 'color': const Color(0xFF10B981)},
    ];

    double startAngle = -pi / 2;

    for (final segment in segments) {
      final paint = Paint()
        ..color = segment['color'] as Color
        ..style = PaintingStyle.fill;

      final sweepAngle = 2 * pi * (segment['value'] as double);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}