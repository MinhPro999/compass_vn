import 'dart:async';
import 'dart:convert';

import 'package:compass_vn/core/state_manager.dart';
import 'package:compass_vn/core/main_compass.dart';
import 'package:compass_vn/widgets/build_infobox_8.dart';

import 'package:compass_vn/utils/compass_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@Deprecated('Sử dụng StateManager() thay thế')
int get guaNumber00 => StateManager().guaNumber;

class BatTrachScreen extends StatefulWidget {
  const BatTrachScreen({
    super.key,
  });

  @override
  BatTrachScreenState createState() => BatTrachScreenState();
}

class BatTrachScreenState extends State<BatTrachScreen> {
  Map<String, dynamic>? compassData;
  final String overlayImagePath = 'assets/images/khung_8.png';
  Map<String, dynamic> huongTotXauMap = {};
  Map<String, dynamic> yNghiaCungMap = {};
  Map<String, dynamic> nenKhongNenMap = {};
  StreamSubscription? _compassSubscription;
  late StateManager _stateManager;

  // Kênh nhận dữ liệu từ native
  static const EventChannel _compassChannel = EventChannel('compass_stream');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'La Bàn Bát Trạch ${_stateManager.gender} ${_stateManager.yearOfBirth}',
          style: const TextStyle(
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
          if (compassData != null)
            Image.asset(
              compassData!['compass'][0]['background'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CompassWidget(
                          compassImagePath:
                              compassData?['compass']?[0]?['co'] ?? '',
                        ),
                        Image.asset(
                          overlayImagePath,
                          height: 400,
                          width: 400,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<double>(
                      stream: _compassChannel
                          .receiveBroadcastStream()
                          .map((event) => event as double),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

                        final double? heading = snapshot.data;

                        if (heading == null) {
                          return const Text(
                            'Không có dữ liệu cảm biến!',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          );
                        }

                        final headingData = getHeadingData(heading);
                        final double? processedHeading = headingData['heading'];
                        final String direction = headingData['direction'];

                        final info = _getDetailedInfo(direction);
                        final Color colorChu = Color(int.parse(
                            info['color_chu']!.replaceAll('0x', '0xFF')));
                        final Color colorBox = Color(int.parse(
                            info['color_box']!.replaceAll('0x', '0xFF')));

                        return BuildInfoBox8(
                          data: {
                            "huong": info['huong'] ?? '',
                            "tot_xau": info['tot_xau'] ?? '',
                            "cung": info['cung'] ?? '',
                            "y_nghia": info['y_nghia'] ?? '',
                            "nen": info['nen'] ?? '',
                            "khong_nen": info['khong_nen'] ?? '',
                          },
                          heading: processedHeading,
                          colorChu: colorChu,
                          colorBox: colorBox,
                        );
                      },
                    ),
                  ],
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
    _compassSubscription?.cancel();
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _stateManager = StateManager();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadJsonData(guaNumber: _stateManager.guaNumber);
  }

  Map<String, String> _getDetailedInfo(String direction) {
    Map<String, String> info = {};
    String directionKey = direction.toLowerCase();

    if (huongTotXauMap.containsKey(directionKey)) {
      var currentData = huongTotXauMap[directionKey];
      info['tot_xau'] = currentData?['tot_xau'] ?? '';
      info['huong'] = currentData?['huong'] ?? '';
      info['cung'] = currentData?['cung'] ?? '';
      info['color_chu'] = currentData?['color_chu'] ?? '0xFFFFFFFF';
      info['color_box'] = currentData?['color_box'] ?? '0xFF000000';
    }

    if (info['cung'] != null && yNghiaCungMap.containsKey(info['cung'])) {
      var cungData = yNghiaCungMap[info['cung']];
      info['y_nghia'] = cungData?['y_nghia'] ?? '';
    }

    if (info['cung'] != null && nenKhongNenMap.containsKey(info['cung'])) {
      var nenData = nenKhongNenMap[info['cung']];
      info['nen'] = nenData?['nen'] ?? '';
      info['khong_nen'] = nenData?['khong_nen'] ?? '';
    }

    return info;
  }

  String _getJsonFileNameJsonFromGua(int guaNumber) {
    Map<int, String> fileMapping = {
      1: 'e1_data.json',
      2: 'w2_data.json',
      3: 'e3_data.json',
      4: 'e4_data.json',
      6: 'w6_data.json',
      7: 'w7_data.json',
      8: 'w8_data.json',
      9: 'e9_data.json',
    };

    return fileMapping[guaNumber] ?? 'e1_data.json';
  }

  Future<void> _loadJsonData({required int guaNumber}) async {
    String fileNameJson = _getJsonFileNameJsonFromGua(guaNumber);

    try {
      final String response =
          await rootBundle.loadString('lib/data/$fileNameJson');
      final data = json.decode(response);
      setState(() {
        compassData = data;

        huongTotXauMap = {
          for (var item in compassData!['huong_tot_xau'])
            item['huong'].toLowerCase(): {
              'huong': item['huong'] ?? '',
              'tot_xau': item['tot_xau'] ?? '',
              'cung': item['cung'] ?? '',
              'color_chu': item['color_chu'] ?? '#FFFFFF',
              'color_box': item['color_box'] ?? '#000000'
            }
        };

        yNghiaCungMap = {
          for (var item in compassData!['y_nghia_cung'])
            item['cung']: {
              'cung': item['cung'] ?? '',
              'y_nghia': item['y_nghia'] ?? ''
            }
        };

        nenKhongNenMap = {
          for (var item in compassData!['nen_khong_nen'])
            item['cung']: {
              'cung': item['cung'] ?? '',
              'nen': item['nen'] ?? '',
              'khong_nen': item['khong_nen'] ?? ''
            }
        };
      });
    } catch (e) {
      debugPrint('Error loading JSON file: $e');
    }
  }

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

    return {
      'heading': angle,
      'direction': CompassUtils.getDirectionFromAngle(angle),
    };
  }
}
