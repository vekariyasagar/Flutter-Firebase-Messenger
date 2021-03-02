
class UserModel {

  UserModel(this.name, this.about_us,this.mobile_no,this.id,this.image_path);

  final String id;
  final String name;
  final String about_us;
  final String image_path;
  final String mobile_no;

  factory UserModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserModel(
      parsedJson['name'].toString(),
      parsedJson['about_us'].toString(),
      parsedJson['mobile_no'].toString(),
      parsedJson['id'].toString(),
      parsedJson['image_path'].toString()
    );
  }

}
