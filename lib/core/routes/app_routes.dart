import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newappgradu/features/auth/presentation/secreen/register_send_code.dart';
import 'package:newappgradu/features/auth/presentation/secreen/splash_screen.dart';
import 'package:newappgradu/features/help/screen/help_screen.dart';
import 'package:newappgradu/features/home/presentation/screen/home_screen.dart';
import 'package:newappgradu/features/home_menu/presintion/all_doctor/all_doctor.dart';
import 'package:newappgradu/features/medicalRe/screens/my_medically_log.dart';
import 'package:newappgradu/features/profile/presentation/secreen/setting_screen.dart';
import 'package:newappgradu/features/auth/presentation/secreen/Onboarding1_splash.dart';
import 'package:newappgradu/features/auth/presentation/secreen/login_screen.dart';
import 'package:newappgradu/features/auth/presentation/secreen/register_screen.dart';
import 'package:newappgradu/features/auth/presentation/secreen/reset_password_screen.dart';
import 'package:newappgradu/features/auth/presentation/secreen/send_code_screen.dart';
import 'package:newappgradu/features/profile/presentation/secreen/change_password_screen.dart';
import 'package:newappgradu/features/profile/presentation/secreen/update_profile_screen.dart';

import '../../features/alarm/screens/addMedicinePromptScreen.dart';
import '../../features/home_menu/presintion/search/screen/doctor_search_page.dart';
import '../../features/profile/presentation/secreen/profile_home_screen.dart';
import '../../main.dart';

class Routes {
  static const String intitlRoute = '/';
  static const String login = '/login';
  static const String sendCode = '/sendCode';
  static const String restPassword = '/restPassword';
  static const String profileHome = '/profileHome';
  static const String updateProfile = '/updateProfile';
  static const String setting = '/setting';
  static const String changePassword = '/changePassword';
  static const String onBoarding1Screen = '/onBoarding1Screen';
  static const String register = '/register';
  static const String home = '/home';
  static const String registerCode = '/register_send_code';
  static const String doctorMenu = '/doctor_menu';
  static const String doctorDetails = '/doctor_details';
  static const String bookingAppointment = '/booking_appointment';
  static const String healthCentersMenu = '/all_doctor';
  static const String searchScreen = '/search';
  static const String logScreen = '/log';
  static const String helpScreen = '/help_screen';
  static const String medicalConsultation = '/medicalConsultation_screen';
  static const String laboratoriesMenu = '/laboratories_menu';
  static const String laboratoriesDetails = '/laboratories_detalis';
  static const String radiologyCenterItemMenu = '/radiology_center_menu';
  static const String radiologyCenterItemDetails = '/radiology_center_detalis';
  static const String pharmaciesMenu = '/pharmacies_menu';
  static const String pharmaciesDetails = '/pharmacies_details';
  static const String myBooking = '/my_booking';
  static const String medicineReminderHome = '/medicineReminderHome';
  static const String addMedicineScreen = '/addMedicineScreen';
}

class AppRoutes {
  static Route? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.intitlRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onBoarding1Screen:
        return MaterialPageRoute(builder: (_) => const OnBoarding1Screen());
      case Routes.logScreen:
        return MaterialPageRoute(builder: (_) =>  MainMenuPage());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.sendCode:
        return MaterialPageRoute(builder: (_) => const SendCodeScreen());
      case Routes.restPassword:
        return MaterialPageRoute(builder: (_) => const ReSetPassword());
      case Routes.profileHome:
        return MaterialPageRoute(builder: (_) => const ProfileHome());
      case Routes.updateProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage(currentUserProfile: {},));
      case Routes.setting:
        return MaterialPageRoute(builder: (_) => SettingScreen());
      case Routes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.medicineReminderHome:
        return MaterialPageRoute(builder: (_) =>  AddMedicinePromptScreen(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,));
      case Routes.registerCode:
        return MaterialPageRoute(builder: (_) => const RegisterSendCode());
      case Routes.healthCentersMenu:
        return MaterialPageRoute(builder: (_) => const AllDoctorsPage());





      case Routes.searchScreen:
        return MaterialPageRoute(builder: (_) => const DoctorSearchPage());
      case Routes.helpScreen:
        return MaterialPageRoute(builder: (_) => const HelpScreen());

      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(
                    child: Text('No Found Route'),
                  ),
                ));
    }
  }
}
