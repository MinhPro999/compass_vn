import 'package:compass_vn/core/main_compass.dart';
import 'package:compass_vn/core/streambuilder_degree.dart';
import 'package:compass_vn/services/facebook_analytics_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompassDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String backgroundImagePath = 'assets/images/screen_dang.jpg';
  final String compassImagePathScreen = 'assets/images/compass.png';
  final String overlayImagePath = 'assets/images/khung_compass.png';

  const CompassDetailScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<CompassDetailScreen> createState() => _CompassDetailScreenState();
}

class _CompassDetailScreenState extends State<CompassDetailScreen> {
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();

    // Track screen view
    FacebookAnalyticsService.logScreenView('basic_compass_screen');
    FacebookAnalyticsService.logCompassUsage();
  }

  @override
  void dispose() {
    // Track session duration
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);
      FacebookAnalyticsService.logSessionDuration(duration.inSeconds);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xF6FFFFFF),
          ),
          onPressed: () {
            SystemChrome.setPreferredOrientations([]);
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'La Bàn Cơ Bản',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xAEBE0A0A),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            widget.backgroundImagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              widget.overlayImagePath,
                              height: 400,
                              width: 400,
                              fit: BoxFit.contain,
                            ),
                            CompassWidget(
                                compassImagePath:
                                    widget.compassImagePathScreen),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const StreamBuilderCompassDegree(),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
