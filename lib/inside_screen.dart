import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_project/constants.dart';
import 'package:news_project/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsideScreen extends StatefulWidget {
  final Blog blog;
  final String imageUrl;
  final Function()? onFavoriteStatusChanged; // Add this callback

  const InsideScreen({Key? key, required this.blog, required this.imageUrl, this.onFavoriteStatusChanged,})
      : super(key: key);

  @override
  State<InsideScreen> createState() => _InsideScreenState();
}

class _InsideScreenState extends State<InsideScreen> {
  bool isFavorite = false;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    checkIsFavorite(); // Check if the blog is already a favorite when the screen loads
  }

  Future<void> toggleFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteBlogs = prefs.getStringList('favoriteBlogs') ?? [];

      setState(() {
        isFavorite = !isFavorite;

        if (isFavorite) {
          favoriteBlogs.add(widget.blog.id!);
        } else {
          favoriteBlogs.remove(widget.blog.id!);
        }

        prefs.setStringList('favoriteBlogs', favoriteBlogs);
      });

      if (widget.onFavoriteStatusChanged != null) {
        widget.onFavoriteStatusChanged!();
      }
    } catch (e) {
      if (e is HttpException) {
        if (e.message.contains("403")) {
          _showErrorSnackBar("You don't have permission to perform this action.");
        } else {
          _showErrorSnackBar("An error occurred: ${e.message}");
        }
      } else {
        _showErrorSnackBar("An unexpected error occurred: $e");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  Future<void> checkIsFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteBlogs = prefs.getStringList('favoriteBlogs') ?? [];
    setState(() {
      isFavorite = favoriteBlogs.contains(widget.blog.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(
                isFavorite
                    ? AppConstants.favorite_rounded
                    : AppConstants.favorite_border_rounded,
              ),
              onPressed: toggleFavorite,
            ),
          ],
          title: Text(
            AppConstants.appName,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.yellow),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.imageUrl != null
                    ? Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                          print("in errorBuilder here");
                    return Image.asset(
                      AppConstants.error,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Placeholder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.blog.title.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
