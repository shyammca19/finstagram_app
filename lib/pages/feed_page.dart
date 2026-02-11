import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FeedPage extends StatefulWidget {
  FeedPage({super.key});

  @override
  State<FeedPage> createState() {
    return _FeedPageState();
  }
}

class _FeedPageState extends State<FeedPage> {
  double? _deviceHeight, _deviceWidth;
  FirebaseService? _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: _deviceHeight!,
      width: _deviceWidth!,
      child: _postListView(),
    );
  }

  Widget _postListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService!.getLatestPosts(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          //print(snapshot.data!);
          //print(snapshot.data!.docs);
          List posts = snapshot.data!.docs.map((e) => e.data()).toList();
          //print(posts);
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext _context, int index) {
              Map post = posts[index];
              return Container(
                height: _deviceHeight! * 0.3,
                margin: EdgeInsets.symmetric(
                  vertical: _deviceHeight! * 0.01,
                  horizontal: _deviceWidth! * 0.05,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(post['image']),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: const CircularProgressIndicator());
        }
      },
    );
  }
}
