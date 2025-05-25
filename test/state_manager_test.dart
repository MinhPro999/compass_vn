import 'package:flutter_test/flutter_test.dart';
import 'package:compass_vn/core/state_manager.dart';

void main() {
  group('StateManager Tests', () {
    late StateManager stateManager;

    setUp(() {
      stateManager = StateManager();
      stateManager.reset(); // Reset state trước mỗi test
    });

    test('should initialize with empty values', () {
      expect(stateManager.gender, isEmpty);
      expect(stateManager.yearOfBirth, isEmpty);
      expect(stateManager.guaNumber, equals(0));
      expect(stateManager.mansion, isEmpty);
      expect(stateManager.hasValidUserInfo, isFalse);
    });

    test('should update gender correctly', () {
      stateManager.updateUserInfo(gender: 'Nam');
      expect(stateManager.gender, equals('Nam'));
      expect(stateManager.genderForCalculation, equals('male'));
    });

    test('should update year of birth correctly', () {
      stateManager.updateUserInfo(yearOfBirth: '1990');
      expect(stateManager.yearOfBirth, equals('1990'));
    });

    test('should calculate gua number correctly for male 1990', () {
      stateManager.updateUserInfo(gender: 'Nam', yearOfBirth: '1990');
      expect(stateManager.hasValidUserInfo, isTrue);
      expect(stateManager.guaNumber, greaterThan(0));
      expect(stateManager.mansion, isNotEmpty);
    });

    test('should calculate gua number correctly for female 1990', () {
      stateManager.updateUserInfo(gender: 'Nữ', yearOfBirth: '1990');
      expect(stateManager.hasValidUserInfo, isTrue);
      expect(stateManager.guaNumber, greaterThan(0));
      expect(stateManager.mansion, isNotEmpty);
    });

    test('should return correct display info', () {
      stateManager.updateUserInfo(gender: 'Nam', yearOfBirth: '1990');
      final displayInfo = stateManager.getDisplayInfo();
      expect(displayInfo, contains('Quái số:'));
      expect(displayInfo, contains('Mệnh:'));
    });

    test('should return error message for incomplete info', () {
      final displayInfo = stateManager.getDisplayInfo();
      expect(displayInfo, equals('Chưa có đủ dữ liệu để tính toán'));
    });

    test('should reset all values', () {
      stateManager.updateUserInfo(gender: 'Nam', yearOfBirth: '1990');
      stateManager.reset();
      
      expect(stateManager.gender, isEmpty);
      expect(stateManager.yearOfBirth, isEmpty);
      expect(stateManager.guaNumber, equals(0));
      expect(stateManager.mansion, isEmpty);
      expect(stateManager.hasValidUserInfo, isFalse);
    });
  });

  group('GuaCalculator Tests', () {
    test('should calculate correct gua number for male born in 1990', () {
      final result = GuaCalculator.determineMansion(1990, 'male');
      expect(result['guaNumber'], isA<int>());
      expect(result['mansion'], isA<String>());
      expect(result.containsKey('error'), isFalse);
    });

    test('should calculate correct gua number for female born in 1990', () {
      final result = GuaCalculator.determineMansion(1990, 'female');
      expect(result['guaNumber'], isA<int>());
      expect(result['mansion'], isA<String>());
      expect(result.containsKey('error'), isFalse);
    });

    test('should return error for invalid gender', () {
      final result = GuaCalculator.determineMansion(1990, 'invalid');
      expect(result.containsKey('error'), isTrue);
    });

    test('should handle gua number 5 correctly for male', () {
      // Tìm năm sinh tạo ra quái số 5 cho nam
      for (int year = 1950; year < 2050; year++) {
        final result = GuaCalculator.determineMansion(year, 'male');
        if (result['guaNumber'] == 5) {
          fail('Quái số 5 không được phép cho nam, nhưng được tìm thấy cho năm $year');
        }
      }
    });

    test('should handle gua number 5 correctly for female', () {
      // Tìm năm sinh tạo ra quái số 5 cho nữ
      for (int year = 1950; year < 2050; year++) {
        final result = GuaCalculator.determineMansion(year, 'female');
        if (result['guaNumber'] == 5) {
          fail('Quái số 5 không được phép cho nữ, nhưng được tìm thấy cho năm $year');
        }
      }
    });
  });
}
