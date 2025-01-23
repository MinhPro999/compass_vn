import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

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
  double _filteredAngle = 0; // Góc đã làm mượt
  final double _alpha = 0.33; // Hệ số làm mượt

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Lỗi khi đọc dữ liệu cảm biến'));
        }

        final CompassEvent? event = snapshot.data;
        final double? direction = event?.heading;

        if (direction == null) {
          return const Center(child: Text('Không có dữ liệu cảm biến'));
        }

        // Chuyển góc âm sang dương
        double newAngle = direction >= 0 ? direction : direction + 360;

        // Tính delta góc (giữa góc mới và góc làm mượt hiện tại)
        double deltaAngle = newAngle - _filteredAngle;

        // Đảm bảo deltaAngle xoay theo hướng ngắn nhất
        if (deltaAngle > 180) {
          deltaAngle -= 360;
        } else if (deltaAngle < -180) {
          deltaAngle += 360;
        }

        // Cập nhật góc đã làm mượt
        _filteredAngle += _alpha * deltaAngle;

        // Giới hạn _filteredAngle trong phạm vi 0–360 để kiểm soát giá trị
        if (_filteredAngle == 0) {
          // Giữ nguyên giá trị 0, không làm gì
        } else if (_filteredAngle >= 360) {
          _filteredAngle -= 360;
        } else if (_filteredAngle < 0) {
          _filteredAngle += 360;
        }

        return Transform.rotate(
          angle: (_filteredAngle * math.pi / 180) *
              -1, // Đổi sang radian và xoay theo chiều âm
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
