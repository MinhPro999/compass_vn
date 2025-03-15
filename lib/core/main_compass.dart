import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompassWidget extends StatefulWidget {
  final String compassImagePath;

  const CompassWidget({
    super.key,
    required this.compassImagePath,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  static const EventChannel _compassChannel = EventChannel('compass_stream');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _compassChannel
          .receiveBroadcastStream()
          .map((event) => event as double),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Lỗi khi đọc dữ liệu cảm biến'));
        }

        final double? filteredAngle = snapshot.data;

        if (filteredAngle == null) {
          return const Center(child: Text('Không có dữ liệu cảm biến'));
        }

        return Transform.rotate(
          angle: (filteredAngle * math.pi / 180) *
              -1, // Đổi sang radian và xoay ngược
          child: Image.asset(
            widget.compassImagePath,
            height: 400,
            width: 400,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
