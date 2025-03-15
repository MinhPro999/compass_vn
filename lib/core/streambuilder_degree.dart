// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StreamBuilderCompassDegree extends StatelessWidget {
  const StreamBuilderCompassDegree({super.key});

  // Kênh nhận dữ liệu từ native
  static const EventChannel _compassChannel = EventChannel('compass_stream');

  // Hàm xác định hướng từ góc (giữ lại vì không liên quan trực tiếp đến cảm biến)
  String getDirectionFromAngle(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'Bắc';
    if (angle >= 22.5 && angle < 67.5) return 'Đông Bắc';
    if (angle >= 67.5 && angle < 112.5) return 'Đông';
    if (angle >= 112.5 && angle < 157.5) return 'Đông Nam';
    if (angle >= 157.5 && angle < 202.5) return 'Nam';
    if (angle >= 202.5 && angle < 247.5) return 'Tây Nam';
    if (angle >= 247.5 && angle < 292.5) return 'Tây';
    if (angle >= 292.5 && angle < 337.5) return 'Tây Bắc';
    return 'Không xác định';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _compassChannel
          .receiveBroadcastStream()
          .map((event) => event as double),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Đang tải dữ liệu...',
            style: TextStyle(fontSize: 16, color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Lỗi khi đọc dữ liệu cảm biến!',
            style: TextStyle(fontSize: 16, color: Colors.white),
          );
        }

        final double? filteredAngle = snapshot.data;

        if (filteredAngle == null) {
          return const Text(
            'Không có dữ liệu cảm biến!',
            style: TextStyle(fontSize: 16, color: Colors.white),
          );
        }

        // Tính hướng từ góc đã làm mượt từ native
        final String direction = getDirectionFromAngle(filteredAngle);

        // Hiển thị dữ liệu góc và hướng
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Hướng: $direction ${filteredAngle.toStringAsFixed(1)}°',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFed1c24),
            ),
          ),
        );
      },
    );
  }
}
