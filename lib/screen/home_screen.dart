// ignore_for_file: deprecated_member_use

import 'package:compass_vn/core/state_manager.dart';
import 'package:compass_vn/screen/screen_compass.dart';
import 'package:compass_vn/screen/screen_compass_8.dart';
import 'package:compass_vn/services/facebook_analytics_service.dart';
import 'package:compass_vn/widgets/funtion_gidview.dart';
import 'package:compass_vn/widgets/user_info_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Track screen view
    FacebookAnalyticsService.logScreenView('home_screen');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(222, 190, 10, 10),
        statusBarIconBrightness: Brightness.light, // Icon trắng
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.1),
              colorBlendMode: BlendMode.srcATop,
            ),
            SafeArea(
              child: Column(
                children: [
                  const UserInfoBar(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chọn La Bàn',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 200,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return funtionGidview(
                                    'assets/images/normal_compass.JPG',
                                    'La bàn cơ bản',
                                    () {
                                      // Track compass selection
                                      FacebookAnalyticsService.logFeatureUsage(
                                          'basic_compass');
                                      FacebookAnalyticsService
                                          .logUserEngagement('compass_selected',
                                              additionalParams: {
                                            'compass_type': 'basic'
                                          });

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CompassDetailScreen(
                                            title: '',
                                            description: '',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return funtionGidview(
                                  'assets/images/24_directions.JPG',
                                  'La bàn theo tuổi',
                                  () {
                                    // Track age compass selection attempt
                                    FacebookAnalyticsService.logUserEngagement(
                                        'age_compass_attempted');

                                    final stateManager = StateManager();
                                    if (!stateManager.hasValidUserInfo) {
                                      // Track missing user info
                                      FacebookAnalyticsService.logEvent(
                                          'user_info_missing', {
                                        'screen': 'home_screen',
                                        'feature': 'age_compass'
                                      });

                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Thông tin bị thiếu!'),
                                          content: const Text(
                                            'Bạn cần lựa chọn giới tính và nhập đầy đủ năm sinh ở ngay phía trên trước khi sử dụng La Bàn này.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('ĐỒNG Ý'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Track successful age compass access
                                      FacebookAnalyticsService.logFeatureUsage(
                                          'age_compass');
                                      FacebookAnalyticsService
                                          .logUserEngagement('compass_selected',
                                              additionalParams: {
                                            'compass_type': 'age_based'
                                          });

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const BatTrachScreen(),
                                        ),
                                      );
                                    }
                                  },
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
            ),
          ],
        ),
      ),
    );
  }
}
