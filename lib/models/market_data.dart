/*
 * DATA MODELS - The "blueprints" for our data
 * 
 * These classes define what information each data type contains.
 * Think of them as forms that must be filled out with specific information.
 */

// MARKET DATA: Stock price information
class MarketData {
  final String symbol;      // Stock symbol (e.g., 'AAPL')
  final double price;       // Current price
  final double change;      // Price change from previous
  final int volume;         // Number of shares traded
  final double marketCap;   // Total company value
  final double pe;          // Price-to-earnings ratio
  final DateTime timestamp; // When this data was created

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

// SYSTEM HEALTH: Server performance metrics
class SystemHealth {
  final int cpuUsage;        // CPU usage percentage
  final int memoryUsage;     // Memory usage percentage
  final int diskUsage;       // Disk usage percentage
  final int networkLatency;  // Network response time (ms)
  final int activeUsers;     // Number of active users
  final int ordersPerSecond; // Trading orders per second
  final Duration uptime;     // How long server has been running

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

// NEWS ALERT: Breaking news information
class NewsAlert {
  final String headline;    // News headline
  final String impact;      // Impact level: HIGH, MEDIUM, LOW
  final String sentiment;   // Market sentiment: POSITIVE, NEGATIVE
  final DateTime timestamp; // When news was published

  NewsAlert({
    required this.headline,
    required this.impact,
    required this.sentiment,
    required this.timestamp,
  });
}

// TRADE EXECUTION: Buy/sell order information
class TradeExecution {
  final String orderId;     // Unique order identifier
  final String symbol;      // Stock symbol
  final String side;        // BUY or SELL
  final int quantity;       // Number of shares
  final double price;       // Execution price
  final String status;      // Order status (FILLED, PENDING, etc.)
  final DateTime timestamp; // When trade was executed

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

// CHART POINT: For price history visualization
class ChartPoint {
  final double price;       // Price at this point
  final DateTime time;      // When this price occurred

  ChartPoint(this.price, this.time);
}