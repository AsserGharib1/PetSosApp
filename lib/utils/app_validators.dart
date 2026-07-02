import 'package:easy_localization/easy_localization.dart';

class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'name_required'.tr();
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'username_required'.tr();
    }
    return null;
  }

  // These static methods provide validation logic for form fields.
  // They ensure data integrity before submission (e.g., checking for valid email format).
  static String? validateEmail(String? value) {
    // Simple check, can be enhanced with Regex for stricter validation
    if (value == null || !value.contains('@')) {
      return 'enter_valid_email'.tr();
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_required'.tr();
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'password_length_error'.tr();
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value != password) {
      return 'passwords_match_error'.tr();
    }
    return null;
  }
}
