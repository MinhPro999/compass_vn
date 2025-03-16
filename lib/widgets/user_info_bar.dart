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
  String _gender = '';
  String birthYear = '';
  final TextEditingController _yearController = TextEditingController();
  final FocusNode _yearFocusNode = FocusNode();
  String _guaResult = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xDEBE0A0A), // Màu nền của user bar
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: Image.asset(
                  'assets/images/icon_app_mini.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 0),
              Expanded(
                child: _buildGenderSelection(),
              ),
              const SizedBox(width: 0),
              SizedBox(
                width: 100,
                child: _buildYearOfBirthField(),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    _yearController.dispose();
    _yearFocusNode.dispose();
    super.dispose();
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _genderRadio('Nam'),
        const SizedBox(width: 0),
        _genderRadio('Nữ'),
      ],
    );
  }

  Widget _buildYearOfBirthField() {
    return TextField(
      textAlign: TextAlign.center,
      controller: _yearController,
      focusNode: _yearFocusNode,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Năm sinh',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xFFFDFC99),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xFFFDFC99),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
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
        LengthLimitingTextInputFormatter(4),
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        _notifyInfoChange();
        if (value.length == 4) {
          _yearFocusNode.unfocus();
        }
      },
    );
  }

  Widget _genderRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _gender,
          onChanged: (newValue) {
            setState(() {
              _gender = newValue!;
              _notifyInfoChange();
              genderGlobal = newValue;
            });
          },
          activeColor: const Color(0xFFC7C400),
        ),
        Text(value, style: const TextStyle(color: Color(0xFFFDFC99))),
      ],
    );
  }

  void _notifyInfoChange() {
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
        birthYear = _yearController.text;
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
          _guaResult = "Chưa có đủ dữ liệu để tính toán";
        });
      }
    }
  }
}
