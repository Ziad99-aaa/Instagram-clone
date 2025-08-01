class UserDate {
  String username;
  String title;
  String password;
  String email;
  String profileImg;

  UserDate({
    required this.username,
    required this.email,
    required this.password,
    required this.title,
    required this.profileImg,
  });

  // To convert the UserData(Data type) to   Map<String, Object>
  Map<String, dynamic> convert2Map() {
    return {
      "username": username,
      'title': title,
      'email': email,
      'password': password,
      'profileImg':profileImg
    };
  }
}
