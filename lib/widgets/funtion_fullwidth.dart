// Widget nội dung toàn bộ chiều ngang
import 'package:flutter/material.dart';

Widget funtionFullWidth(String imagePath, String title) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Không chiếm không gian thừa
        children: [
          // Ảnh bên trên
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: 120, // Chiều cao ảnh
              width: double.infinity,
            ),
          ),
          // Tiêu đề bên dưới ảnh
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
