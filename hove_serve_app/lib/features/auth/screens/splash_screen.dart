import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _backgroundColor = Color(0xFFB9E6F8);
  static const _brandColor = Color(0xFF075B73);
  static const _buttonColor = Color(0xFF126D85);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(31, 48, 31, 66),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'assets/images/app_icon.png',
                width: 148,
                height: 148,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              const Text(
                'HomeServe',
                style: TextStyle(
                  color: _brandColor,
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 45,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/register'),
                  icon: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  label: const Icon(Icons.arrow_forward, size: 19),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 19),
              TextButton(
                onPressed: () => context.go('/login'),
                style: TextButton.styleFrom(
                  foregroundColor: _brandColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Color(0xFF052C3A),
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: _brandColor,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
