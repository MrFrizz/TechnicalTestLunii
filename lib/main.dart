// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}

  void testAsync() async {
//    final url = "https://api.github.com/users/Steven-K-JOHNSON/repos";
    final url = "https://api.github.com/users/MrFrizz/repos";
    final response = await http.get(url);

    final json = jsonDecode(response.body);

//    print(json);
//    print('\n');
//    print(json[0]["id"]);
//    print('\n');
//    print(json[0]["owner"]["login"]);

    for(final value in json) {
      print(value["name"]);
    }
  }
