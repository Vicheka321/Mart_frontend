class Validators {
  Validators._();

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!re.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone is required';
    final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 8) return 'Enter a valid phone number';
    return null;
  }

  static String? loginField(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email or phone is required';
    final isEmail = v.contains('@');
    if (isEmail) return email(v);
    return phone(v.replaceAll(RegExp(r'[^\d]'), ''));
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Add a lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add a number';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v))
      return 'Add a special character';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.length != 6) return 'Enter 6-digit OTP';
    return null;
  }
}

class PasswordStrength {
  static int score(String password) {
    int s = 0;
    if (password.length >= 8) s++;
    if (password.length >= 12) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) s++;
    return s;
  }

  static String label(int score) {
    if (score <= 1) return 'Weak';
    if (score <= 3) return 'Fair';
    if (score == 4) return 'Good';
    return 'Strong';
  }
}