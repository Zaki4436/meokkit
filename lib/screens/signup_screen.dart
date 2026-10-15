import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/app_messages.dart';
import '../widgets/app_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? _formError;
  String? _formSuccess;

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(_clearFormFeedback);
    usernameController.addListener(_clearFormFeedback);
    passwordController.addListener(_clearFormFeedback);
    confirmPasswordController.addListener(_clearFormFeedback);
  }

  void _clearFormFeedback() {
    if (_formError != null || _formSuccess != null) {
      setState(() {
        _formError = null;
        _formSuccess = null;
      });
    }
  }

  void _setFormError(String message) {
    setState(() {
      _formError = message;
      _formSuccess = null;
    });
  }

  Future<void> _signup() async {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (fullName.isEmpty) {
      _setFormError('Sila masukkan nama penuh anda.');
      return;
    }

    if (username.isEmpty) {
      _setFormError('Sila masukkan No. Matrik anda.');
      return;
    }

    if (password.isEmpty) {
      _setFormError('Sila masukkan kata laluan anda.');
      return;
    }

    if (password.length < 6) {
      _setFormError('Kata laluan mesti sekurang-kurangnya 6 aksara.');
      return;
    }

    if (password != confirmPassword) {
      _setFormError('Kata laluan dan pengesahan kata laluan tidak sepadan.');
      return;
    }

    setState(() {
      loading = true;
      _formError = null;
      _formSuccess = null;
    });

    final result = await ApiService.post({
      'action': 'register',
      'matrik_no': username,
      'username': username,
      'user_id': username,
      'full_name': fullName,
      'password': password,
    });

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (result['success'] == true) {
      fullNameController.clear();
      usernameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      setState(() {
        _formSuccess = AppMessages.registerSuccess;
      });
    } else {
      _setFormError(
        result['message']?.toString() ??
            AppMessages.getErrorMessage(
              result['error'],
              defaultMessage: 'Pendaftaran akaun gagal. Sila cuba lagi.',
            ),
      );
    }
  }

  @override
  void dispose() {
    fullNameController.removeListener(_clearFormFeedback);
    usernameController.removeListener(_clearFormFeedback);
    passwordController.removeListener(_clearFormFeedback);
    confirmPasswordController.removeListener(_clearFormFeedback);

    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD94B4B),
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/icon/app_name.png',
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Daftar Akaun Baru',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFieldContainer(
                        child: TextField(
                          controller: usernameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'No. Matrik',
                            Icons.person_outline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildFieldContainer(
                        child: TextField(
                          controller: fullNameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Nama Penuh',
                            Icons.badge_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildFieldContainer(
                        child: TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Kata Laluan',
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip: obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildFieldContainer(
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Sahkan Kata Laluan',
                            Icons.lock_reset_outlined,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip: obscureConfirmPassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: 14),
                        _buildFeedbackBanner(
                          message: _formError!,
                          isSuccess: false,
                        ),
                      ],
                      if (_formSuccess != null) ...[
                        const SizedBox(height: 14),
                        _buildFeedbackBanner(
                          message: _formSuccess!,
                          isSuccess: true,
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: loading ? null : _signup,
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar Akaun',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Sudah mempunyai akaun? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Log Masuk',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner({
    required String message,
    required bool isSuccess,
  }) {
    final backgroundColor =
        isSuccess ? const Color(0xFFEDF8F0) : const Color(0xFFFFF0F0);
    final borderColor =
        isSuccess ? const Color(0xFFC5E7CE) : const Color(0xFFF3CACA);
    final foregroundColor =
        isSuccess ? const Color(0xFF256B2A) : const Color(0xFFB71C1C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: foregroundColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}