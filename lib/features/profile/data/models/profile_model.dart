class ProfileModel {
  final String name;

  final String dateBirthday;
  final String gender;
  final String phone;


  ProfileModel({

    required this.phone,
    required this.gender,
    required this.dateBirthday,
    required this.name,

  });

  factory ProfileModel.formJson(json) {
    return ProfileModel(

        phone: json['phone'],
        gender: json['gender'],
      dateBirthday: json['dateBirthday'],
        name: json['First_Name'] +" "+json['Last_Name'],
        );
  }
  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
