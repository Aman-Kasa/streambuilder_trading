/*
 * PRICE CHART WIDGET - StreamBuilder with Custom Painting
 * 
 * This widget demonstrates StreamBuilder with custom graphics.
 * Shows real-time price chart updates using CustomPainter.
 */

import 'package:flutter/material.dart';
import 'dart:math';
import '../models/market_data.dart';

class PriceChart extends StatelessWidget {
  final Stream<MarketData> stream;
  final List<ChartPoint> priceHistory;

  const PriceChart({
    super.key,
    required this.stream,
    required this.priceHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B).withOpacity(0.9),
            const Color(0xFF334155).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              // 🔴 STREAMBUILDER: Live price indicator
              StreamBuilder<MarketData>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      'Loading...',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${snapshot.data!.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Chart area
          Expanded(
            child: StreamBuilder<MarketData>(
              stream: stream,
              builder: (context, snapshot) {
                if (priceHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      'Collecting price data...',
                      style: TextStyle(color: Colors.white60),
                    ),
                  );
                }
                
                return CustomPaint(
                  painter: ChartPainter(priceHistory),
                  size: Size.infinite,
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Chart labels
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
}

// Custom painter for the price chart
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

    // Calculate price range
    final minPrice = points.map((p) => p.price).reduce(min);
    final maxPrice = points.map((p) => p.price).reduce(max);
    final priceRange = maxPrice - minPrice;
    
    if (priceRange == 0) return; // Avoid division by zero

    // Draw price line
    final linePaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < points.length; i++) {
      final x = (i / max(1, points.length - 1)) * size.width;
      final normalizedPrice = (points[i].price - minPrice) / priceRange;
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
      final normalizedPrice = (points[i].price - minPrice) / priceRange;
      final y = size.height - (normalizedPrice * size.height);
      canvas.drawCircle(Offset(x, y), 2, pointPaint);
    }

    // Draw price labels on Y-axis
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

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
      
      // Draw background for text
      final textRect = Rect.fromLTWH(
        -5, 
        y - textPainter.height / 2, 
        textPainter.width + 10, 
        textPainter.height
      );
      canvas.drawRect(
        textRect, 
        Paint()..color = const Color(0xFF1E293B).withOpacity(0.8)
      );
      
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}