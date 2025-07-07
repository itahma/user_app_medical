import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/presentation/screen/home_screen.dart';
import 'Onboarding1_splash.dart';
import 'login_screen_patient.dart'; // استيراد شاشة تسجيل الدخول
// استورد شاشتك الرئيسية هنا
// import 'package:newappgradu/features/patient/home/screens/home_screen.dart';

class SplashScreenOne extends StatefulWidget {
  const SplashScreenOne({super.key});

  @override
  State<SplashScreenOne> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenOne> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // انتظار لمدة ثانيتين لعرض الشعار
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-jwt');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // إذا وُجد توكن، انتقل إلى الشاشة الرئيسية مباشرة مع مسح الشاشات السابقة
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()), // استبدلها بالشاشة الرئيسية لديك
            (route) => false,
      );
    } else {
      // إذا لم يوجد توكن، انتقل إلى شاشة تسجيل الدخول مع مسح الشاشات السابقة
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnBoarding1Screen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.healing, color: Colors.white, size: 120),
            SizedBox(height: 20),
            Text(
                'تطبيق العناية الصحية',
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2
                )
            ),
          ],
        ),
      ),
    );
  }
}

