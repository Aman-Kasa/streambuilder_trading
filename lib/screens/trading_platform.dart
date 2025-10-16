/*
 * TRADING PLATFORM SCREEN - The main UI controller
 * 
 * This screen manages the tab navigation and connects the UI to the data service.
 * It demonstrates how StreamBuilder widgets consume data from streams.
 * 
 * KEY STREAMBUILDER PATTERN:
 * StreamBuilder<DataType>(
 *   stream: service.dataStream,     // Listen to data
 *   builder: (context, snapshot) {  // Build UI
 *     return Widget(snapshot.data); // Show data
 *   }
 * )
 */

import 'package:flutter/material.dart';
import '../services/trading_service.dart';
import '../models/market_data.dart';
import '../widgets/market_overview.dart';
import '../widgets/news_feed.dart';
import '../widgets/system_monitor.dart';
import '../widgets/price_chart.dart';

class TradingPlatform extends StatefulWidget {
  const TradingPlatform({super.key});

  @override
  State<TradingPlatform> createState() => _TradingPlatformState();
}

class _TradingPlatformState extends State<TradingPlatform>
    with TickerProviderStateMixin {
  
  // ========== CONTROLLERS ==========
  late TabController _tabController;
  late TradingService _tradingService;  // Our data service

  @override
  void initState() {
    super.initState();
    
    // Set up tab navigation (5 tabs)
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize data service and start streaming
    _tradingService = TradingService();
    _tradingService.startStreams();  // Start the "TV broadcasts"
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tradingService.dispose();  // Stop all streams and timers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      
      // ========== APP BAR WITH TABS ==========
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
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.show_chart), text: 'Charts'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Portfolio'),
            Tab(icon: Icon(Icons.newspaper), text: 'News'),
            Tab(icon: Icon(Icons.monitor_heart), text: 'System'),
          ],
        ),
      ),
      
      // ========== TAB CONTENT ==========
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

  // ========== TAB 1: DASHBOARD ==========
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔴 MAIN STREAMBUILDER: Live market data
          MarketOverview(stream: _tradingService.marketStream),
          const SizedBox(height: 16),
          
          // Stats and trades row
          Row(
            children: [
              Expanded(child: _buildQuickStats()),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentTrades()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Mini chart preview
          Container(
            height: 200,
            child: PriceChart(
              stream: _tradingService.marketStream,
              priceHistory: _tradingService.priceHistory,
            ),
          ),
        ],
      ),
    );
  }

  // ========== TAB 2: CHARTS ==========
  Widget _buildChartsView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔴 STREAMBUILDER: Live price chart with custom painting
          PriceChart(
            stream: _tradingService.marketStream,
            priceHistory: _tradingService.priceHistory,
          ),
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

  // ========== TAB 3: PORTFOLIO ==========
  Widget _buildPortfolioView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔴 STREAMBUILDER: Live portfolio value
          StreamBuilder<MarketData>(
            stream: _tradingService.marketStream,
            builder: (context, snapshot) {
              final portfolioChange = _tradingService.portfolioValue - 125000;
              final isPositive = portfolioChange >= 0;
              
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
                        const Text(
                          'PORTFOLIO VALUE',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white70),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '\$${_tradingService.portfolioValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isPositive ? '+' : ''}\$${portfolioChange.toStringAsFixed(2)} (${((portfolioChange / 125000) * 100).toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Portfolio breakdown
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

  // ========== TAB 4: NEWS ==========
  Widget _buildNewsView() {
    return Column(
      children: [
        _buildNewsHeader(),
        // 🔴 STREAMBUILDER: Live news feed
        Expanded(
          child: NewsFeed(stream: _tradingService.newsStream),
        ),
      ],
    );
  }

  // ========== TAB 5: SYSTEM ==========
  Widget _buildSystemView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔴 STREAMBUILDER: System health monitoring
          SystemMonitor(stream: _tradingService.systemStream),
          const SizedBox(height: 16),
          _buildResourceUsage(),
        ],
      ),
    );
  }

  // ========== HELPER WIDGETS ==========
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
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<MarketData>(
            stream: _tradingService.marketStream,
            builder: (context, snapshot) {
              final price = snapshot.hasData ? snapshot.data!.price : 150.25;
              return Column(
                children: [
                  _buildStatRow('Day High', '\$${(price + 2.2).toStringAsFixed(2)}', Colors.green),
                  _buildStatRow('Day Low', '\$${(price - 1.8).toStringAsFixed(2)}', Colors.red),
                  _buildStatRow('52W High', '\$198.23', Colors.blue),
                  _buildStatRow('52W Low', '\$124.17', Colors.orange),
                ],
              );
            },
          ),
        ],
      ),
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
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          // 🔴 STREAMBUILDER: Live trade feed
          StreamBuilder<TradeExecution>(
            stream: _tradingService.tradeStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Column(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.white60, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Waiting for trades...',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                );
              }
              final trade = snapshot.data!;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (trade.side == 'BUY' ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: trade.side == 'BUY' ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trade.side,
                          style: TextStyle(
                            color: trade.side == 'BUY' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          trade.status,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trade.quantity} shares @ \$${trade.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order: ${trade.orderId}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicators() {
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
            'TECHNICAL INDICATORS',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<MarketData>(
            stream: _tradingService.marketStream,
            builder: (context, snapshot) {
              return Column(
                children: [
                  _buildIndicatorRow('RSI', '${45 + (snapshot.hasData ? (snapshot.data!.price % 20).toInt() : 0)}', Colors.purple),
                  _buildIndicatorRow('MACD', snapshot.hasData ? '${(snapshot.data!.change).toStringAsFixed(2)}' : '0.00', Colors.orange),
                  _buildIndicatorRow('SMA(20)', snapshot.hasData ? '\$${(snapshot.data!.price - 2).toStringAsFixed(2)}' : '\$148.00', Colors.blue),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildIndicatorRow(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<MarketData>(
            stream: _tradingService.marketStream,
            builder: (context, snapshot) {
              final currentPrice = snapshot.hasData ? snapshot.data!.price : 150.25;
              return Column(
                children: [
                  _buildHoldingRow('AAPL', 'Apple Inc.', 100, currentPrice),
                  _buildHoldingRow('MSFT', 'Microsoft Corp.', 50, 420.50),
                  _buildHoldingRow('GOOGL', 'Alphabet Inc.', 25, 2850.75),
                ],
              );
            },
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

  Widget _buildNewsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.newspaper, color: Colors.white),
          SizedBox(width: 12),
          Text('Live Market News', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResourceUsage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RESOURCE USAGE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('CPU: 25%', style: TextStyle(color: Colors.blue)),
          Text('Memory: 55%', style: TextStyle(color: Colors.purple)),
          Text('Disk: 68%', style: TextStyle(color: Colors.orange)),
        ],
      ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAllocationRow('Stocks', 65, Colors.blue),
                _buildAllocationRow('Bonds', 25, Colors.green),
                _buildAllocationRow('Cash', 10, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllocationRow(String asset, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            asset,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
          StreamBuilder<MarketData>(
            stream: _tradingService.marketStream,
            builder: (context, snapshot) {
              return Column(
                children: [
                  _buildMetricRow('1D Return', '+2.34%', Colors.green),
                  _buildMetricRow('1W Return', '+5.67%', Colors.green),
                  _buildMetricRow('1M Return', '-1.23%', Colors.red),
                  _buildMetricRow('YTD Return', '+12.45%', Colors.green),
                ],
              );
            },
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
          const Text(
            'TRADING VOLUME',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<MarketData>(
              stream: _tradingService.marketStream,
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(8, (index) {
                    final volume = 50 + (snapshot.hasData ? (snapshot.data!.volume % 150) : 100);
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
        ],
      ),
    );
  }
}