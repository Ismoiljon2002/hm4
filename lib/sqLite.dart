import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  List<Map<String, dynamic>> postsFromSQLite = [];

  @override
  void initState() {
    super.initState();
    // Fetch user data from the SQLite database
    getPostsFromSQLite();
  }

  // Function to fetch user data from the SQLite database
  Future<void> getPostsFromSQLite() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using a hardcoded path is not recommended for production.
      join(await getDatabasesPath(), 'post.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database
        return db.execute(
          'CREATE TABLE IF NOT EXISTS posts(id INTEGER PRIMARY KEY, title TEXT, body TEXT)',
        );
      },
      version: 1,
    );

    // Query the database for all posts
    final List<Map<String, dynamic>> posts = await database.then((db) {
      return db.query('posts');
    });

    setState(() {
      postsFromSQLite = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts from SQLite'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Expanded(
            child: ListView.builder(
              itemCount: postsFromSQLite.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(postsFromSQLite[index]['title']),
                  subtitle: Text(postsFromSQLite[index]['body']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}