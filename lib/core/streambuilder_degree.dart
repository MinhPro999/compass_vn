import 'package:compass_vn/screen/screen_compass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

// Hàm tái sử dụng để xử lý dữ liệu góc và hướng
Map<String, dynamic> getHeadingData(double? angle) {
  if (angle == null) {
    return {
      'heading': null,
      'direction': 'Không xác định',
    };
  }

  // Chuyển góc âm thành góc dương
  if (angle < 0) {
    angle += 360;
  }

  // Tính toán hướng từ góc
  String direction = getDirectionFromAngle(angle);

  return {
    'heading': angle,
    'direction': direction,
  };
}

class StreamBuilderCompassDegree extends StatelessWidget {
  const StreamBuilderCompassDegree({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final CompassEvent? event = snapshot.data;

        // Sử dụng hàm tái sử dụng để xử lý góc và hướng
        final headingData = getHeadingData(event?.heading);
        final double? heading = headingData['heading'];
        final String direction = headingData['direction'];

        if (heading == null) {
          return const Text(
            'Không có dữ liệu cảm biến!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          );
        }

        // Hiển thị dữ liệu góc và hướng
        return Container(
          margin: const EdgeInsets.only(top: 8), // Lề trên
          padding: const EdgeInsets.all(12), // Đệm bên trong
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12), // Bo góc
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8, // Độ mờ của bóng
                offset: const Offset(0, 4), // Độ lệch của bóng
              ),
            ],
          ),
          child: Text(
            'Hướng: $direction ${heading.toStringAsFixed(1)}°',
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
