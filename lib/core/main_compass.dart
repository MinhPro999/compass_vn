// ignore_for_file: avoid_print

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
  late final Stream<double> _compassStream;

  @override
  void initState() {
    super.initState();
    _compassStream = _compassChannel.receiveBroadcastStream().map((event) {
      if (event is double) return event;
      if (event is int) return event.toDouble();
      debugPrint('Dữ liệu không phải kiểu số: $event (${event.runtimeType})');
      return 0.0;
    }).handleError((error) {
      debugPrint('Lỗi compass stream: $error');
      return 0.0; // Giá trị mặc định khi lỗi
    });
  }

  @override
  void dispose() {
    // EventChannel không cần dispose thủ công, nhưng giữ để mở rộng nếu cần
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _compassStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Lỗi stream trong build: ${snapshot.error}');
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  'Lỗi khi đọc dữ liệu cảm biến',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final double? filteredAngle = snapshot.data;

        if (filteredAngle == null) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sensors_off, size: 48, color: Colors.orange),
                SizedBox(height: 8),
                Text(
                  'Không có dữ liệu cảm biến',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Vui lòng kiểm tra quyền truy cập cảm biến',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Sử dụng kích thước linh hoạt dựa trên chiều rộng màn hình
        double size = MediaQuery.of(context).size.width * 0.8; // 80% chiều rộng
        return Transform.rotate(
          angle: (filteredAngle * math.pi / 180) *
              -1, // Đổi sang radian và xoay ngược
          child: Image.asset(
            widget.compassImagePath,
            height: size,
            width: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Lỗi tải hình ảnh la bàn: $error');
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_not_supported,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Lỗi tải hình ảnh la bàn',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
