import 'package:compass_vn/core/culcalator_monster.dart';
import 'package:compass_vn/screen/screen_compass.dart';
import 'package:compass_vn/screen/screen_compass_8.dart';
import 'package:compass_vn/widgets/funtion_gidview.dart';
import 'package:compass_vn/widgets/user_info_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(222, 190, 10, 10),
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Stack(
            children: [
              // Ảnh nền
              Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.1),
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
                                  return index == 0
                                      ? funtionGidview(
                                          'assets/images/normal_compass.JPG',
                                          'La bàn cơ bản',
                                          () {
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
                                        )
                                      : funtionGidview(
                                          'assets/images/24_directions.JPG',
                                          'La bàn theo tuổi',
                                          () {
                                            // Kiểm tra xem giới tính hoặc năm sinh có bị rỗng không
                                            if (genderGlobal.isEmpty ||
                                                yearGlobal.isEmpty) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Thông tin bị thiếu!'),
                                                  content: const Text(
                                                      'Bạn cần lựa chọn giới tính và nhập đầy đủ năm sinh ở ngay phía trên trước khi sử dụng La Bàn này.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Đóng dialog
                                                      },
                                                      child:
                                                          const Text('ĐỒNG Ý'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
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
        ));
  }
}
