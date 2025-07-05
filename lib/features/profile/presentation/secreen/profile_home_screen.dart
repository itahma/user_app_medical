import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/features/booking/presentation/screeen/my_booking.dart';
import 'package:newappgradu/features/profile/presentation/cubit/setting_cubit/setting_cubit.dart';
import 'package:newappgradu/features/profile/presentation/cubit/setting_cubit/setting_state.dart';
import '../../../../core/utils/app_string.dart';
import '../../../medicalRe/screens/my_medically_log.dart';

class ProfileHome extends StatefulWidget {
  const ProfileHome({Key? key}) : super(key: key);

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocConsumer<SettingCubit, SettingState>(
        listener: (_, state) {
          if (state is ErrorLoadProfile) {
            showToast(message: state.error, state: ToastState.error);
          }
        },
        builder: (_, state) {
          if (state is LoadingProfile) {
            return Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
              ),
            );
          }

          if (state is LoadedProfile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoSection(context, state),
                  const SizedBox(height: 30),
                  Divider(height: 20, thickness: 1, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  _buildOptionItem(
                    context,
                    icon: Icons.feed_outlined,
                    label: AppString.medicalRecord.tr(context),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MainMenuPage())),
                  ),
                  _buildOptionItem(
                    context,
                    icon: Icons.book_outlined,
                    label: AppString.myBooking.tr(context),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MyBookingsPage())),
                  ),
                  _buildOptionItem(
                    context,
                    icon: Icons.settings,
                    label: AppString.settings.tr(context),
                    onTap: () =>
                        navigate(context: context, route: Routes.setting),
                  ),
                  _buildOptionItem(
                    context,
                    icon: Icons.support,
                    label: AppString.support.tr(context),
                    onTap: () =>
                        navigate(context: context, route: Routes.helpScreen),
                  ),
                  _buildOptionItem(
                    context,
                    icon: Icons.alarm_add_outlined,
                    label: 'منبه الدواء',
                    onTap: () =>
                        navigate(context: context, route: Routes.medicineReminderHome),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 20, thickness: 1, color: Colors.grey[300]),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildProfileInfoSection(BuildContext context, LoadedProfile state) {


    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // اسم المستخدم بتصميم احترافي
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  state.profileModel.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // باقي المعلومات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoCard(
                icon: Icons.cake,
                label:
                '${DateTime.now().year - DateTime.parse(state.profileModel.dateBirthday).year}',
                title: "العمر",
              ),
              _buildInfoCard(
                icon: Icons.phone,
                label: state.profileModel.phone,
                title: "الهاتف",
              ),
              _buildInfoCard(
                icon: Icons.male_outlined,
                label: state.profileModel.gender,
                title: "الجنس",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(width: 20),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

