const String userTable = 'user';


class UserFields {
  static const String username = 'username';
  static const String name = 'name';
  static final List<String> allFields = [username, name];
}

class User {

  User({
    required this.username,
    required this.name,
  });
  final String username;
  String name;

  Map<String,Object> toJson()=>{
  UserFields.username : username,
  UserFields.name: name,
  };

  static User fromJson(Map<String, Object?> json) => User(
    username: json[UserFields.username]! as String,
    name: json[UserFields.name]! as String,
  );
}
