import 'dart:convert';

class UserModel {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:       json['id'] as int,
        fullName: json['full_name'] as String,
        email:    json['email'] as String?,
        phone:    json['phone'] as String?,
        role:     json['role'] as String? ?? 'customer',
        avatar:   json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':        id,
        'full_name': fullName,
        'email':     email,
        'phone':     phone,
        'role':      role,
        'avatar':    avatar,
      };

  String get displayLogin => email ?? phone ?? '';
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  static UserModel? fromJsonString(String? s) {
    if (s == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());
}

// ─── API Response Wrappers ────────────────────────────────

class AuthResult {
  final String message;
  final String? accessToken;
  final UserModel? user;

  const AuthResult({required this.message, this.accessToken, this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        message:     json['message'] as String,
        accessToken: json['access_token'] as String?,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

class OtpResult {
  final String message;
  final String? resetToken;

  const OtpResult({required this.message, this.resetToken});

  factory OtpResult.fromJson(Map<String, dynamic> json) => OtpResult(
        message:    json['message'] as String,
        resetToken: json['reset_token'] as String?,
      );
}

class ResetResult {
  final String message;
  final String? token;
  final UserModel? user;

  const ResetResult({required this.message, this.token, this.user});

  factory ResetResult.fromJson(Map<String, dynamic> json) => ResetResult(
        message: json['message'] as String,
        token:   json['token'] as String?,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}