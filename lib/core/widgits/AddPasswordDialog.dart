import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/feature_home/domain/PasswordEntity.dart';
import '../../features/feature_home/domain/PasswordStrength.dart';
import '../../features/feature_home/domain/SiteCategoryClassifier.dart';
import '../../features/feature_home/presentation/bloc/home_bloc.dart';
import '../../features/feature_home/presentation/bloc/home_event.dart';
import 'PasswordStrengthBar.dart';

class AddPasswordDialog extends StatefulWidget {
  const AddPasswordDialog({super.key});

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final siteCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  PasswordStrength? _strength;
  bool _obscurePassword = true;

  @override
  void dispose() {
    siteCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{};:,.<>?';

    final rand = Random.secure();
    final length = 12 + rand.nextInt(4);
    final all = letters + numbers + symbols;

    return List.generate(length, (_) => all[rand.nextInt(all.length)]).join();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final detectedCategory = SiteCategoryClassifier.detect(
      siteCtrl.text.trim(),
    );

    context.read<PasswordBloc>().add(
      AddPassword(
        PasswordEntity(
          id: null,
          site: siteCtrl.text.trim(),
          username: userCtrl.text.trim(),
          password: passCtrl.text.trim(),
          category: detectedCategory,
          isfav: false,
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Add Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _buildTextField(
                      controller: siteCtrl,
                      label: 'Website / App',
                      icon: Icons.public,
                    ),

                    const SizedBox(height: 18),

                    _buildTextField(
                      controller: userCtrl,
                      label: 'Username',
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    /// Password Field
                    TextFormField(
                      controller: passCtrl,
                      obscureText: _obscurePassword,
                      onChanged: (value) {
                        setState(() {
                          _strength = value.isEmpty
                              ? null
                              : calculatePasswordStrength(value);
                        });
                      },
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Password is required'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.blueAccent,
                        ),
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          final generated = _generatePassword();
                          setState(() {
                            passCtrl.text = generated;
                            _strength = calculatePasswordStrength(generated);
                          });
                        },
                        icon: const Icon(Icons.auto_fix_high, size: 16),
                        label: const Text(
                          'Generate strong password',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _strength == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: PasswordStrengthBar(
                                key: ValueKey(_strength),
                                strength: _strength!,
                              ),
                            ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: (v) =>
          v == null || v.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}