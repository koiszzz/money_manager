import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/app_router.dart';

class PinLockPage extends StatefulWidget {
  const PinLockPage({super.key});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  final List<int> _digits = [];
  int _failedAttempts = 0;
  bool _cooldown = false;

  void _addDigit(int digit) {
    if (_cooldown) return;
    setState(() {
      if (_digits.length < 4) {
        _digits.add(digit);
      }
    });
    if (_digits.length == 4) {
      _validatePin();
    }
  }

  void _removeDigit() {
    if (_cooldown || _digits.isEmpty) return;
    setState(() {
      _digits.removeLast();
    });
  }

  Future<void> _validatePin() async {
    final pin = _digits.join();
    final appState = context.read<AppState>();
    if (pin == appState.pinCode) {
      if (!mounted) return;
      context.go(AppRoutes.main);
    } else {
      _failedAttempts += 1;
      setState(() => _digits.clear());
      if (_failedAttempts >= 3) {
        setState(() => _cooldown = true);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _cooldown = false;
            _failedAttempts = 0;
          });
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).pinError)));
      }
    }
  }

  void _forgotPin() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).forgotPinTitle),
        content: Text(AppLocalizations.of(context).forgotPinBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2632),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Symbols.lock, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('Bookkeeper Pro',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF16202B),
                ),
                child: Center(
                  child: Text(strings.secureAccess.toUpperCase(),
                      style: const TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 24),
              Text(strings.welcomeBack.trim(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                _cooldown ? strings.pleaseWait : strings.enterPin,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _digits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color:
                          filled ? const Color(0xFF2B7CEE) : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? const Color(0xFF2B7CEE)
                            : Colors.grey.shade500,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _cooldown ? null : _forgotPin,
                child: Text(strings.forgotPin),
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return _ActionKey(
                        icon: Symbols.face,
                        onPressed: _cooldown ? null : () {},
                      );
                    }
                    if (index == 10) {
                      return _NumberKey(
                        label: '0',
                        onPressed: _cooldown ? null : () => _addDigit(0),
                      );
                    }
                    if (index == 11) {
                      return _ActionKey(
                        icon: Symbols.backspace,
                        onPressed: _cooldown ? null : _removeDigit,
                      );
                    }
                    final number = index + 1;
                    return _NumberKey(
                      label: '$number',
                      onPressed: _cooldown ? null : () => _addDigit(number),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 18),
                height: 4,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberKey extends StatelessWidget {
  const _NumberKey({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 30,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF141E2A),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 30,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF141E2A),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
