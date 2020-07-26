// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.yellow[800],
        title: Text('Users Repository'),
      ),
      body: Container(
        child: Column(
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
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          fontSize: 22.0
                        ),
                      ),
                    ),
                  );
                }
                else if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final userRepos = snapshot.data;

                return Container(
                  height: size.height-165,
                  child: Column(
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: userRepos.reposModel.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                onTap: () => launchRepoURL(userRepos.reposModel[index].reposLink),
                                contentPadding: EdgeInsets.all(8.0),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${userRepos.reposModel[index].reposName}',
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        color: Colors.yellow[900],
                                      ),
                                    ),
                                    Divider(thickness: 2.0,)
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        '${userRepos.reposModel[index].reposDesc}'
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      '${userRepos.reposModel[index].reposLink}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline
                                      )
                                    )
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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

  launchRepoURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<UserReposModel> getReposOfUser(String username) async {
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
    else throw Exception('An unhandled error as occur');

  }
