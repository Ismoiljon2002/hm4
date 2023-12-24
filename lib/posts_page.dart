import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'sqLite.dart';
// Import the ThirdScreen

class PostsPage extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostsPage> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  Future<void> _getPosts() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load post data');
    }
  }
  
  Future<void> _storeDataInDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'posts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS posts(id INTEGER PRIMARY KEY, title TEXT, body TEXT)',
        );
      },
      version: 1,
    );

    await database.then((db) async {
      for (var post in posts) {
        await db.insert(
          'posts',
          {
            'title': post['title'],
            'body': post['body'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Posts'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    posts[index]['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
                    ),
                  subtitle: Text(posts[index]['body']),
                  onTap: () {
                    _storeDataInDatabase();
                  },
                );
              },
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _storeDataInDatabase();
                },
                child: Text('Store in SQLite'),
              ),
              ElevatedButton(
                onPressed: () {
                  
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => ThirdScreen(),
                      transitionsBuilder: (context, animation1, animation2, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation1.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                      transitionDuration: Duration(milliseconds: 200),
                    ),
                  );
                },
                child: Text('SQLite Posts'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}