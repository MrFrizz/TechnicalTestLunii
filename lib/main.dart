// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'ReposModel.dart';
import 'UserReposModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: UserReposScreen(),
    );
  }
}

class UserReposScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<UserReposModel>(
          future: getReposOfUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userRepos = snapshot.data;

              return Text("Name : ${userRepos.username}" );
            } else if (snapshot.hasError) {
              return Text("ERROR");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}


  Future<UserReposModel> getReposOfUser() async {
    final url = "https://api.github.com/users/MrFrizz/repos";
    final response = await http.get(url);
    List<ReposModel> reposModels = List<ReposModel>();

    if (response.statusCode == 200) {
      final jsonRepos = jsonDecode(response.body);
      for(final value in jsonRepos)
        reposModels.add(ReposModel.fromJson(value));

      return UserReposModel.fromJson(jsonRepos, reposModels);

    } else {
      throw Exception("User not find");
    }
  }
