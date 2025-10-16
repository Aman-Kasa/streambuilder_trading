/*
 * SYSTEM MONITOR WIDGET - StreamBuilder Example #3
 * 
 * This widget demonstrates StreamBuilder with numerical data and progress indicators.
 * Shows how real-time system metrics can be displayed.
 */

import 'package:flutter/material.dart';
import '../models/market_data.dart';

class SystemMonitor extends StatelessWidget {
  final Stream<SystemHealth> stream;

  const SystemMonitor({
    super.key,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    // 🔴 STREAMBUILDER EXAMPLE: System health monitoring
    return StreamBuilder<SystemHealth>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }
        
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
              // Header
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
              
              // Key metrics row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthMetric(
                    'Active Users', 
                    '${health.activeUsers}', 
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildHealthMetric(
                    'Orders/sec', 
                    '${health.ordersPerSecond}', 
                    Icons.speed,
                    Colors.green,
                  ),
                  _buildHealthMetric(
                    'Uptime', 
                    '${health.uptime.inHours}h', 
                    Icons.timer,
                    Colors.purple,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Resource usage bars
              _buildResourceBar('CPU Usage', health.cpuUsage, Colors.blue),
              const SizedBox(height: 12),
              _buildResourceBar('Memory Usage', health.memoryUsage, Colors.purple),
              const SizedBox(height: 12),
              _buildResourceBar('Disk Usage', health.diskUsage, Colors.orange),
              
              const SizedBox(height: 16),
              
              // Network latency
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Network Latency',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${health.networkLatency}ms',
                    style: TextStyle(
                      color: health.networkLatency < 20 ? Colors.green : Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget for health metrics
  Widget _buildHealthMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
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

  // Helper widget for resource usage bars
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

  // Loading state
  Widget _buildLoadingState() {
    return Container(
      height: 300,
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
              'Loading system metrics...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}