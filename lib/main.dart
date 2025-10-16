/*
 * STREAMBUILDER TRADING PLATFORM - PROFESSIONAL STRUCTURE
 * 
 * This app demonstrates StreamBuilder widget usage with proper Flutter architecture.
 * 
 * 🎯 KEY CONCEPTS FOR PRESENTATION:
 * 1. StreamBuilder - Widget that rebuilds UI when new data arrives
 * 2. StreamController - Creates data streams (like TV channels)
 * 3. Timer.periodic - Sends data at regular intervals
 * 4. Real-time UI updates without manual refresh
 * 
 * 📁 PROJECT STRUCTURE:
 * ├── models/          - Data classes (MarketData, NewsAlert, etc.)
 * ├── services/        - Data generation and streaming logic
 * ├── screens/         - Main UI screens
 * ├── widgets/         - Reusable StreamBuilder components
 * └── main.dart        - App entry point (this file)
 * 
 * 🔴 STREAMBUILDER LOCATIONS:
 * - MarketOverview widget: Live stock prices
 * - NewsFeed widget: Breaking news alerts
 * - SystemMonitor widget: Server health metrics
 * - TradingPlatform screen: Portfolio and trade data
 */

import 'package:flutter/material.dart';
import 'screens/trading_platform.dart';

// ========== APP ENTRY POINT ==========
// This starts the entire application
void main() {
  runApp(const StreamBuilderApp());
}

// ========== ROOT APP WIDGET ==========
// Sets up the app theme and navigation
class StreamBuilderApp extends StatelessWidget {
  const StreamBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamBuilder Pro - Trading Platform',
      debugShowCheckedModeBanner: false,
      
      // Dark theme for professional trading look
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),  // Blue accent color
          brightness: Brightness.dark,          // Dark mode
        ),
      ),
      
      // Main trading platform screen
      home: const TradingPlatform(),
    );
  }
}

/*
 * 🎬 PRESENTATION FLOW:
 * 
 * 1. START HERE (main.dart) - Show clean entry point
 * 2. NAVIGATE TO services/trading_service.dart - Show data streaming setup
 * 3. SHOW widgets/market_overview.dart - Perfect StreamBuilder example
 * 4. DEMO THE APP - Show live updates in action
 * 5. EXPLAIN ARCHITECTURE - Professional separation of concerns
 * 
 * 💡 KEY TALKING POINTS:
 * - "StreamBuilder automatically rebuilds UI when data changes"
 * - "No manual setState() calls needed"
 * - "Professional project structure for scalability"
 * - "Multiple StreamBuilders can listen to same stream"
 * - "Easy to add new data streams and UI components"
 */