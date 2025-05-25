import 'package:flutter/foundation.dart';

/// StateManager để quản lý state toàn cục thay thế cho global variables
class StateManager extends ChangeNotifier {
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  // User info state
  String _gender = '';
  String _yearOfBirth = '';
  int _guaNumber = 0;
  String _mansion = '';

  // Getters
  String get gender => _gender;
  String get yearOfBirth => _yearOfBirth;
  int get guaNumber => _guaNumber;
  String get mansion => _mansion;

  // Computed properties
  bool get hasValidUserInfo => _gender.isNotEmpty && _yearOfBirth.isNotEmpty;
  
  String get genderForCalculation {
    switch (_gender) {
      case 'Nam':
        return 'male';
      case 'Nữ':
        return 'female';
      default:
        return '';
    }
  }

  /// Cập nhật thông tin người dùng
  void updateUserInfo({
    String? gender,
    String? yearOfBirth,
  }) {
    bool hasChanged = false;

    if (gender != null && gender != _gender) {
      _gender = gender;
      hasChanged = true;
    }

    if (yearOfBirth != null && yearOfBirth != _yearOfBirth) {
      _yearOfBirth = yearOfBirth;
      hasChanged = true;
    }

    if (hasChanged) {
      _calculateGuaNumber();
      notifyListeners();
    }
  }

  /// Tính toán quái số và mệnh
  void _calculateGuaNumber() {
    if (!hasValidUserInfo) {
      _guaNumber = 0;
      _mansion = '';
      return;
    }

    try {
      final yearOfBirth = int.parse(_yearOfBirth);
      final result = GuaCalculator.determineMansion(yearOfBirth, genderForCalculation);
      
      if (result.containsKey('error')) {
        _guaNumber = 0;
        _mansion = '';
      } else {
        _guaNumber = result['guaNumber'] ?? 0;
        _mansion = result['mansion'] ?? '';
      }
    } catch (e) {
      debugPrint('Lỗi khi tính toán quái số: $e');
      _guaNumber = 0;
      _mansion = '';
    }
  }

  /// Reset tất cả state
  void reset() {
    _gender = '';
    _yearOfBirth = '';
    _guaNumber = 0;
    _mansion = '';
    notifyListeners();
  }

  /// Lấy thông tin hiển thị cho UI
  String getDisplayInfo() {
    if (!hasValidUserInfo) {
      return "Chưa có đủ dữ liệu để tính toán";
    }

    if (_guaNumber == 0) {
      return "Lỗi khi tính toán";
    }

    return "Quái số: $_guaNumber, Mệnh: $_mansion";
  }
}

/// GuaCalculator class để tính toán quái số
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
