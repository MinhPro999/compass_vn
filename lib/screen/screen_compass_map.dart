import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompassMapScreen extends StatefulWidget {
  const CompassMapScreen({
    super.key,
    required String title,
    required String description,
  });

  @override
  State<CompassMapScreen> createState() => _CompassMapScreenState();
}

class _CompassMapScreenState extends State<CompassMapScreen> {
  GoogleMapController? _mapController;
  double _heading = 0; // Góc được làm mượt từ native

  // Vị trí khởi tạo – thay đổi theo nhu cầu của bạn
  static const LatLng _initialLocation = LatLng(37.4219999, -122.0840575);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _initialLocation,
    zoom: 16,
  );

  // Kênh nhận dữ liệu từ native
  static const EventChannel _compassChannel = EventChannel('compass_stream');

  @override
  void initState() {
    super.initState();
    // Khóa chế độ xoay màn hình (portrait)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Lắng nghe stream từ native và cập nhật góc
    _compassChannel.receiveBroadcastStream().listen((event) {
      final double filteredAngle = event as double;
      setState(() {
        _heading = filteredAngle;
      });
      _updateMapCameraBearing(_heading);
    }, onError: (error) {
      debugPrint('Lỗi nhận dữ liệu từ native: $error');
    });
  }

  /// Cập nhật camera của Google Map với bearing mới
  void _updateMapCameraBearing(double bearing) {
    if (_mapController != null) {
      final CameraPosition newPosition = CameraPosition(
        target: _initialLocation,
        zoom: 16,
        bearing: bearing,
      );
      try {
        _mapController!
            .animateCamera(CameraUpdate.newCameraPosition(newPosition));
      } catch (e) {
        debugPrint('Lỗi animateCamera: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map làm background
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            rotateGesturesEnabled: false, // Vô hiệu hóa xoay bằng cử chỉ
          ),
          // Hiển thị góc hiện tại (tùy chọn, có thể xóa nếu không cần)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hướng: ${_heading.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    SystemChrome.setPreferredOrientations([]); // Khôi phục chế độ xoay
    super.dispose();
  }
}
