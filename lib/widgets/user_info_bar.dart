import 'package:compass_vn/core/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@Deprecated('Sử dụng StateManager() thay thế')
String get genderGlobal => StateManager().gender;

class UserInfoBar extends StatefulWidget {
  final Function(String yearOfBirth, String gender)? onInfoChanged;

  const UserInfoBar({super.key, this.onInfoChanged});

  @override
  State<UserInfoBar> createState() => _UserInfoBarState();
}

class _UserInfoBarState extends State<UserInfoBar> {
  final TextEditingController _yearController = TextEditingController();
  final FocusNode _yearFocusNode = FocusNode();
  late StateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _stateManager = StateManager();
    _stateManager.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    setState(() {});
  }

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
            _stateManager.getDisplayInfo(),
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
    _stateManager.removeListener(_onStateChanged);
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
          groupValue: _stateManager.gender,
          onChanged: (newValue) {
            _stateManager.updateUserInfo(gender: newValue);
            _notifyInfoChange();
          },
          activeColor: const Color(0xFFC7C400),
        ),
        Text(value, style: const TextStyle(color: Color(0xFFFDFC99))),
      ],
    );
  }

  void _notifyInfoChange() {
    // Cập nhật StateManager với thông tin mới
    _stateManager.updateUserInfo(
      gender: _stateManager.gender,
      yearOfBirth: _yearController.text,
    );

    // Thông báo cho widget cha nếu có callback
    if (widget.onInfoChanged != null) {
      widget.onInfoChanged!(_yearController.text, _stateManager.gender);
    }
  }
}
