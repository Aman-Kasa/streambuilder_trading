/*
 * MARKET OVERVIEW WIDGET - StreamBuilder Example #1
 * 
 * This widget demonstrates the core StreamBuilder pattern:
 * 1. Listen to a data stream
 * 2. Automatically rebuild when new data arrives
 * 3. Show loading/error states
 * 
 * PERFECT FOR EXPLAINING STREAMBUILDER TO YOUR PROFESSOR!
 */

import 'package:flutter/material.dart';
import '../models/market_data.dart';

class MarketOverview extends StatelessWidget {
  final Stream<MarketData> stream;  // The data stream to listen to

  const MarketOverview({
    super.key,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    // 🔴 THIS IS THE MAIN STREAMBUILDER EXAMPLE!
    return StreamBuilder<MarketData>(
      stream: stream,                    // Listen to market data stream
      initialData: MarketData(           // Show this while waiting for real data
        symbol: 'AAPL',
        price: 150.25,
        change: 0,
        volume: 75000,
        marketCap: 2.8e12,
        pe: 28.5,
        timestamp: DateTime.now(),
      ),
      builder: (context, snapshot) {     // This rebuilds automatically when new data arrives!
        
        // Handle different states
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }

        // We have data! Build the UI
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
              // Header with stock symbol and live indicator
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
                  // Live indicator
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
              
              // Price and change display
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Current price
                  Text(
                    '\$${data.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Price change
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
              
              // Market stats
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

  // Helper widget for stats
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

  // Loading state widget
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00D4FF)),
            SizedBox(height: 16),
            Text(
              'Loading market data...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState(String error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading data: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}