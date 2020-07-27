import 'package:test_tech_lunii/Models/ReposModel.dart';

class UserReposModel {
  final String username;
  final String avatar;
  List<ReposModel> reposModel;

  UserReposModel({
    this.username,
    this.avatar,
    this.reposModel
  });

  @override
  String toString() {
    return "$username $avatar number of repository : " + reposModel.length.toString();
  }

  factory UserReposModel.fromJson(final json, List<ReposModel> reposModels) {
    return UserReposModel(
      username: json[0]["owner"]["login"],
      avatar: json[0]["owner"]["avatar_url"],
      reposModel: reposModels
    );
  }
}