import 'package:flutter/material.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import '../../../core/utils/app_string.dart';
import '../drug/screens/drug_list_screen.dart';
import 'medicalAccounts.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MedicalAccounts()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff91BAEF).withOpacity(.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                //Border.all
                height: 55,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calculate_outlined,
                        size: 25,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 30),
                      Text(
                        AppString.medicalAccounts.tr(context),
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DrugListScreen()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff91BAEF).withOpacity(.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                //Border.all
                height: 55,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calculate_outlined,
                        size: 25,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 30),
                      Text(
                        'مجموعة من الأدوية ',
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
