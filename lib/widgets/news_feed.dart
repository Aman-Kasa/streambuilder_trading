/*
 * NEWS FEED WIDGET - StreamBuilder Example #2
 * 
 * This widget shows how StreamBuilder works with lists and real-time updates.
 * Perfect for demonstrating how UI automatically updates when new data arrives.
 */

import 'package:flutter/material.dart';
import '../models/market_data.dart';

class NewsFeed extends StatelessWidget {
  final Stream<NewsAlert> stream;

  const NewsFeed({
    super.key,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    // 🔴 STREAMBUILDER EXAMPLE: Live news feed
    return StreamBuilder<NewsAlert>(
      stream: stream,
      builder: (context, snapshot) {
        // Show message while waiting for first news
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF00D4FF)),
                SizedBox(height: 16),
                Text(
                  'Waiting for breaking news...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        // Build scrollable news list
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5, // Show last 5 news items
          itemBuilder: (context, index) {
            // For demo, we'll show the latest news with slight variations
            final news = snapshot.data!;
            
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
                  // News header with impact and sentiment
                  Row(
                    children: [
                      // Impact badge
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
                      // Sentiment icon
                      Icon(
                        news.sentiment == 'POSITIVE' 
                          ? Icons.trending_up 
                          : Icons.trending_down,
                        size: 16,
                        color: news.sentiment == 'POSITIVE' 
                          ? Colors.green 
                          : Colors.red,
                      ),
                      const Spacer(),
                      // Timestamp
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
                  // News headline
                  Text(
                    news.headline,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Additional info for demo
                  Text(
                    'Market impact expected within 15 minutes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
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

  // Helper method to get color based on impact level
  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper method to format timestamp
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}