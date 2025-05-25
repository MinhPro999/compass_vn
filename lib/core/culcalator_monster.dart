// File này đã được deprecated, logic đã chuyển sang state_manager.dart
// Giữ lại để tương thích với code cũ, sẽ được loại bỏ trong phiên bản tiếp theo

import 'package:compass_vn/core/state_manager.dart';

@Deprecated('Sử dụng StateManager() thay thế')
String get yearGlobal => StateManager().yearOfBirth;

@Deprecated('Sử dụng StateManager() thay thế')
class GuaCalculator {
  static Map<String, dynamic> determineMansion(int yearOfBirth, String gender) {
    int lastTwoDigitsSum = (yearOfBirth % 10) + ((yearOfBirth ~/ 10) % 10);

    if (lastTwoDigitsSum >= 10) {
      lastTwoDigitsSum = (lastTwoDigitsSum % 10) + (lastTwoDigitsSum ~/ 10);
    }

    int guaNumber;
    if (gender.toLowerCase() == 'male') {
      guaNumber =
          yearOfBirth < 2000 ? (10 - lastTwoDigitsSum) : (9 - lastTwoDigitsSum);
    } else if (gender.toLowerCase() == 'female') {
      guaNumber =
          yearOfBirth < 2000 ? (5 + lastTwoDigitsSum) : (6 + lastTwoDigitsSum);
    } else {
      return {
        'error': 'Giới tính không hợp lệ. Hãy nhập "male" hoặc "female".'
      };
    }

    if (guaNumber >= 10) {
      guaNumber = (guaNumber % 10) + (guaNumber ~/ 10);
    }

    if (guaNumber == 5) {
      if (gender.toLowerCase() == 'male') {
        guaNumber = 2;
      } else if (gender.toLowerCase() == 'female') {
        guaNumber = 8;
      }
    }

    String mansion =
        ([1, 3, 4, 9].contains(guaNumber)) ? 'Đông Tứ Mệnh' : 'Tây Tứ Mệnh';

    return {'guaNumber': guaNumber, 'mansion': mansion};
  }
}
