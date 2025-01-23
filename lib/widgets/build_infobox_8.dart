import 'package:flutter/material.dart';

class BuildInfoBox8 extends StatelessWidget {
  final Map<String, String?> data;
  final double? heading; // Thêm heading vào đây
  final Color colorChu; // Màu chữ
  final Color colorBox; // Màu box

  const BuildInfoBox8({
    super.key,
    required this.data,
    this.heading,
    required this.colorChu,
    required this.colorBox,
  });

  @override
  Widget build(BuildContext context) {
    String combinedContent = "";

    double displayHeading = heading ?? 0;
    if (displayHeading < 0) {
      displayHeading += 360;
    }

    if (data['huong'] != null && data['huong']!.isNotEmpty) {
      combinedContent += "Hướng:";
      if (heading != null) {
        combinedContent +=
            " ${displayHeading.toStringAsFixed(1)}° ${data['huong']}";
      }
    }

    if (data['tot_xau'] != null && data['tot_xau']!.isNotEmpty) {
      combinedContent += " là ${data['tot_xau']}\n";
    }

    if (data['cung'] != null && data['cung']!.isNotEmpty) {
      combinedContent += "Thuộc cung: ${data['cung']}\n";
    }
    if (data['y_nghia'] != null && data['y_nghia']!.isNotEmpty) {
      combinedContent += "Ý nghĩa: ${data['y_nghia']}\n";
    }
    if (data['nen'] != null && data['nen']!.isNotEmpty) {
      combinedContent += "Nên: ${data['nen']}\n";
    }
    if (data['khong_nen'] != null && data['khong_nen']!.isNotEmpty) {
      combinedContent += "Không nên: ${data['khong_nen']}\n";
    }

    if (combinedContent.endsWith("\n")) {
      combinedContent =
          combinedContent.substring(0, combinedContent.length - 1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      width: 400, // Đặt chiều rộng cố định
      height: 190, // Đặt chiều cao cố định
      decoration: BoxDecoration(
        color: colorBox.withOpacity(0.68686868),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.268268),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Text(
          combinedContent,
          style: TextStyle(
            fontSize: 17,
            color: colorChu,
          ),
        ),
      ),
    );
  }
}
