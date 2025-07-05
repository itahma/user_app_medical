class ArticlesModel {
  final String title;
  final String text;
  final String doctorName;
  final String ?doctorProfile;
  final String doctorId;
  final String? photo;

  ArticlesModel({
    required this.title,
    required this.text,
    required this.doctorName,
    required this.photo,
    required this.doctorProfile,required this.doctorId
  });

  factory ArticlesModel.fromJson(json) {
    return ArticlesModel(
        title: json['title'],
        text: json['text'],
        doctorName: json['from']['First_Name']+" "+json['from']['Last_Name'],
        photo: json['photo'],
      doctorProfile:json['from']['profile'] ,
      doctorId: json['from']["_id"]

    );
  }
}
