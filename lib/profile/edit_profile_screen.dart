import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mart_frontend/models/profile_model.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/api_service.dart';
import '../screens/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════
// EDIT PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════

class EditProfileScreen extends StatefulWidget {
  final MyProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _avatarScale;

  File? _avatarFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.profile.fullName);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phone ?? '');

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animCtrl,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _avatarScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    HapticFeedback.lightImpact();
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _avatarFile = File(image.path);
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showDialog(
        title: 'Missing Name',
        message: 'Please enter your full name to continue.',
        isError: true,
      );
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() => _saving = true);

    try {
      await ApiService().updateProfile(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        avatar: _avatarFile,
      );

      if (!mounted) return;
      await context.read<ProfileProvider>().fetchProfile();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      await _showDialog(
        title: 'Update Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _showDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final colors = context.colors;
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isError ? colors.flashBg : colors.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isError ? colors.flashText : colors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.text1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: colors.text2),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _AppBar(colors: colors),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    // ── Avatar ──
                    ScaleTransition(
                      scale: _avatarScale,
                      child: _AvatarPicker(
                        colors: colors,
                        avatarFile: _avatarFile,
                        avatarUrl: widget.profile.avatar,
                        fallbackInitial: widget.profile.fullName.isNotEmpty
                            ? widget.profile.fullName[0].toUpperCase()
                            : '?',
                        onTap: _pickAvatar,
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Text(
                        'Tap to change photo',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.text3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Form ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileInput(
                              controller: _nameCtrl,
                              hint: 'Your full name',
                              label: 'Full Name',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 18),
                            _ProfileInput(
                              controller: _emailCtrl,
                              hint: 'you@example.com',
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 18),
                            _ProfileInput(
                              controller: _phoneCtrl,
                              hint: '+855 •• ••• •••',
                              label: 'Phone',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Save button ──
            FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                decoration: BoxDecoration(
                  color: colors.background,
                  border: Border(
                    top: BorderSide(color: colors.border, width: 0.5),
                  ),
                ),
                child: _SaveButton(
                  label: 'Save Changes',
                  isLoading: _saving,
                  onTap: _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppColors colors;
  const _AppBar({required this.colors});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
              color: colors.text2,
            ),
          ),
        ),
      ),
      title: Text(
        'Edit Profile',
        style: TextStyle(
          color: colors.text1,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: colors.border),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AVATAR PICKER
// ═══════════════════════════════════════════════════════════════

class _AvatarPicker extends StatefulWidget {
  final AppColors colors;
  final File? avatarFile;
  final String? avatarUrl;
  final String fallbackInitial;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.colors,
    required this.avatarFile,
    required this.avatarUrl,
    required this.fallbackInitial,
    required this.onTap,
  });

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    ImageProvider? image;
    if (widget.avatarFile != null) {
      image = FileImage(widget.avatarFile!);
    } else if (widget.avatarUrl != null) {
      image = NetworkImage(widget.avatarUrl!);
    }

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: image == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.accent,
                          Color.lerp(colors.accent, Colors.black, 0.18)!,
                        ],
                      )
                    : null,
                border: Border.all(color: colors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: image != null
                  ? ClipOval(
                      child: Image(image: image, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Text(
                        widget.fallbackInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE INPUT
// ═══════════════════════════════════════════════════════════════

class _ProfileInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _ProfileInput({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_ProfileInput> createState() => _ProfileInputState();
}

class _ProfileInputState extends State<_ProfileInput> {
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _focused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _focused ? colors.accent : colors.text2,
              letterSpacing: 0.2,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focused ? colors.accent : colors.border,
              width: _focused ? 1.6 : 1,
            ),
            color: colors.surface2,
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: colors.text1,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: colors.text3, fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  widget.icon,
                  size: 19,
                  color: _focused ? colors.accent : colors.text3,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 50,
              ),
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SAVE BUTTON
// ═══════════════════════════════════════════════════════════════

class _SaveButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _SaveButton({required this.label, this.onTap, this.isLoading = false});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.isLoading ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
