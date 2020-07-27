import 'dart:convert';

import 'package:test_tech_lunii/Models/ReposModel.dart';
import 'package:test_tech_lunii/Models/UserReposModel.dart';
import 'package:http/http.dart' as http;

Future<UserReposModel> getReposOfUser(String username) async {
  if (username.isEmpty)
    return null;
  final url = 'https://api.github.com/users/' + username + '/repos';
  final response = await http.get(url);
  List<ReposModel> reposModels = List<ReposModel>();
  if (response.statusCode == 200) {
    final jsonRepos = jsonDecode(response.body);
    for(final value in jsonRepos)
      reposModels.add(ReposModel.fromJson(value));

    if (reposModels.length == 0) throw Exception('The user own 0 public repository');

    return UserReposModel.fromJson(jsonRepos, reposModels);
  } else if (response.statusCode == 404) throw Exception('The user does not exist');
  else if (response.statusCode == 403) throw Exception('Rate limit error');
  else if (response.statusCode == 443) throw Exception('You are not connected to internet');
  else throw Exception('An unhandled error as occur');

}