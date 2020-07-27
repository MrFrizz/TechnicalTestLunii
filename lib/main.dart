// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:test_tech_lunii/Models/UserReposModel.dart';
import 'package:test_tech_lunii/api/gitCalls.dart' as gitCalls;

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
  String usernameInputOnChanged = '';

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
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
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
                          controller.text = '';
                        },
                        onChanged: (input) {
                          usernameInputOnChanged = input;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        iconSize: 30.0,
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            usernameInput = usernameInputOnChanged;
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                          controller.text = '';
                          usernameInputOnChanged = '';
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Expanded(
              flex: 6,
              child: FutureBuilder<UserReposModel>(
                future: gitCalls.getReposOfUser(usernameInput),
                builder: (context, snapshot) {
                  if (!snapshot.hasError && snapshot.data == null)
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Center(
                          child: Text(
                            'To search repositories from a user, type it in the field and pressed the search icon.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontStyle: FontStyle.italic
                            ),
                          ),
                        ),
                      ),
                    );
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
//                    height: size.height-165,
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
            ),
          ],
        ),
      )
    );
  }
}

launchRepoURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
