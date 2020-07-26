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

class UserReposScreen extends StatefulWidget {
  @override
  _UserReposScreenState createState() => _UserReposScreenState();
}

class _UserReposScreenState extends State<UserReposScreen> {

  final TextEditingController controller = new TextEditingController();

  String usernameInput = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.yellow[800],
        title: Text('Users Repository'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(19))
                ),
                contentPadding: EdgeInsets.all(10.0),
                hintText: 'Find user\'s Github repository',
                hintStyle: TextStyle(fontSize: 20.0, color: Colors.grey[400])
              ),
              onSubmitted: (input) {
                setState(() {
                  usernameInput = input;
                });
                controller.text = "";
              },
            ),
          ),
          SizedBox(height: 5.0),
          FutureBuilder<UserReposModel>(
            future: getReposOfUser(usernameInput),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Text('Error');
              else if (!snapshot.hasData) {
                print('ON EST LA');
                return CircularProgressIndicator();
              }

              final userRepos = snapshot.data;

              return Column(
                children: <Widget>[
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image(
                        image: NetworkImage(userRepos.avatar),
                        width: 100.0,
                        height: 100.0,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            "${userRepos.username}",
                            style: TextStyle(
                              fontSize: userRepos.username.length > 10 ? 18 : 28.0,
                              color: Colors.yellow[900],
                            ),
                          ),

                        ],
                      )
                    ],
                  ),
                  Divider(height: 30.0, thickness: 1.0, indent: 15.0, endIndent: 15.0,),
                  ListView.builder(
                    scrollDirection: Axis.vertical,

                    shrinkWrap: true,
                    itemCount: userRepos.reposModel.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(userRepos.reposModel[index].reposName),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      )
    );
  }
}

//FutureBuilder<UserReposModel>(
//future: getReposOfUser(),
//builder: (context, snapshot) {
//if (snapshot.hasData) {
//final userRepos = snapshot.data;
//
//return Image.network(userRepos.avatar);
////              return Text("Name : ${userRepos.username}" );
//} else if (snapshot.hasError) {
//return Text('ERROR');
//}
//
//return CircularProgressIndicator();
//},
//),

  Future<UserReposModel> getReposOfUser(String username) async {
    final url = 'https://api.github.com/users/' + username + '/repos';
    final response = await http.get(url);
    List<ReposModel> reposModels = List<ReposModel>();

    if (response.statusCode == 200) {
      final jsonRepos = jsonDecode(response.body);
      for(final value in jsonRepos)
        reposModels.add(ReposModel.fromJson(value));

      return UserReposModel.fromJson(jsonRepos, reposModels);

    } else {
      throw Exception('User not find');
    }
  }
