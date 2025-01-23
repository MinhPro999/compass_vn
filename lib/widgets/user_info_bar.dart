import 'package:compass_vn/core/culcalator_monster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String genderGlobal = "";

class UserInfoBar extends StatefulWidget {
  final Function(String yearOfBirth, String gender)? onInfoChanged;

  const UserInfoBar({super.key, this.onInfoChanged});

  @override
  State<UserInfoBar> createState() => _UserInfoBarState();
}

class _UserInfoBarState extends State<UserInfoBar> {
  String _gender = ''; // Giá trị mặc định
  String birthYear = ''; // Giá trị mặc định
  final TextEditingController _yearController = TextEditingController();
  final FocusNode _yearFocusNode = FocusNode();
  String _guaResult = ''; // Kết quả quái số và mệnh

  @override
  Widget build(BuildContext context) {
    // Cài đặt giao diện status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xDEBE0A0A),
      ),
    );

    return Container(
      color: const Color(0xDEBE0A0A), // Màu nền của status bar
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              SizedBox(
                height: 48, // Chiều cao của container chứa ảnh
                width: 48, // Chiều rộng của container chứa ảnh
                child: Image.asset(
                  'assets/images/icon_app_mini.png',
                  fit: BoxFit.contain, // Đảm bảo ảnh không bị méo
                ),
              ),
              const SizedBox(width: 0), // Khoảng cách giữa logo và radio
              // Chọn giới tính
              Expanded(
                child: _buildGenderSelection(),
              ),
              const SizedBox(width: 0), // Khoảng cách giữa radio và ô nhập năm
              // Nhập năm sinh
              SizedBox(
                width: 100, // Đặt chiều rộng cố định cho TextField
                child: _buildYearOfBirthField(),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Hiển thị quái số và mệnh
          Text(
            _guaResult,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _yearController.dispose(); // Giải phóng tài nguyên
    _yearFocusNode.dispose(); // Giải phóng tài nguyên FocusNode
    super.dispose();
  }

  // Widget chọn giới tính
  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _genderRadio('Nam'),
        const SizedBox(width: 0), // Khoảng cách giữa các radio
        _genderRadio('Nữ'),
      ],
    );
  }

  // Widget nhập năm sinh
  Widget _buildYearOfBirthField() {
    return TextField(
      textAlign: TextAlign.center,
      controller: _yearController,
      focusNode: _yearFocusNode, // Gắn FocusNode để quản lý focus
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Năm sinh',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xFFFDFC99), // Màu viền
            width: 2, // Độ dày viền
          ),
        ),
        enabledBorder: OutlineInputBorder(
          // Viền khi ô không được nhấn
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xFFFDFC99),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          // Viền khi ô được nhấn vào
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xFFC7C400),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(4), // Giới hạn nhập 4 ký tự
        FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
      ],
      onChanged: (value) {
        _notifyInfoChange(); // Gọi logic cập nhật thông tin
        if (value.length == 4) {
          // Nếu đủ 4 số, ẩn bàn phím
          _yearFocusNode.unfocus();
        }
      },
    );
  }

  // Radio button cho giới tính
  Widget _genderRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _gender,
          onChanged: (newValue) {
            setState(() {
              _gender = newValue!;
              _notifyInfoChange(); // Cập nhật logic tính toán khi giới tính thay đổi
              genderGlobal = newValue;
            });
          },
          activeColor: const Color(0xFFC7C400),
        ),
        Text(value, style: const TextStyle(color: Color(0xFFFDFC99))),
      ],
    );
  }

  // Gọi callback khi thông tin thay đổi
  void _notifyInfoChange() {
    // Ánh xạ giới tính từ tiếng Việt sang tiếng Anh
    final genderMapping = {'Nam': 'male', 'Nữ': 'female'};
    final mappedGender = genderMapping[_gender];

    if (widget.onInfoChanged != null) {
      widget.onInfoChanged!(_yearController.text, _gender);
    }

    if (_yearController.text.isNotEmpty && mappedGender != null) {
      try {
        final yearOfBirth = int.parse(_yearController.text);
        final result =
            GuaCalculator.determineMansion(yearOfBirth, mappedGender);

        if (result.containsKey('error')) {
          setState(() {
            _guaResult = "Lỗi: ${result['error']}";
          });
        } else {
          final guaNumber = result['guaNumber'].toString();
          final mansion = result['mansion'];
          setState(() {
            _guaResult = "Quái số: $guaNumber, Mệnh: $mansion";
          });
        }
      } catch (e) {
        debugPrint("Lỗi khi tính toán: $e");
      }
    } else {
      setState(() {
        birthYear = _yearController.text; // Cập nhật giá trị năm sinh
      });

      if (_yearController.text.isNotEmpty && mappedGender != null) {
        try {
          final yearOfBirth = int.parse(_yearController.text);
          final result =
              GuaCalculator.determineMansion(yearOfBirth, mappedGender);

          if (result.containsKey('error')) {
            setState(() {
              _guaResult = "Lỗi: ${result['error']}";
            });
          } else {
            final guaNumber = result['guaNumber'].toString();
            final mansion = result['mansion'];
            setState(() {
              _guaResult = "Quái số: $guaNumber, Mệnh: $mansion";
            });
          }
        } catch (e) {
          debugPrint("Lỗi khi tính toán: $e");
        }
      } else {
        setState(() {
          _guaResult = "Chưa có đủ dữ liệu để tính toán.";
        });
      }
    }
  }
}
