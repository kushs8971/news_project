import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_project/constants.dart';
import 'package:news_project/favorites.dart';
import 'package:news_project/inside_screen.dart';
import 'package:news_project/news_model.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Blog> blogs = [];
  List<Blog> filteredBlogs = [];

  bool isLoading = false;

  int _startIndex = 0;
  int _batchSize = 10;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (isLoading) {
                return _buildShimmerLoading();
              } else {
                return _buildBlogList();
              }
            }
        )
      ),
    );
  }

  void fetchData() async {
    print("Api Called");
    setState(() {
      isLoading = true;
    });
    // Define the URL and headers
    final url = Uri.parse('https://intent-kit-16.hasura.app/api/rest/blogs');
    print("Here Now");
    final headers = {
      'x-hasura-admin-secret':
          '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6',
    };
    print("Here Now Two");

    try {
      // Send a GET request
      final response = await http.get(url, headers: headers);

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> blogsData = data['blogs'];
        final List<Blog> blogs =
            blogsData.map((item) => Blog.fromJson(item)).toList();
        print("Here Now Three");

        // Now, you have a list of Blog objects (blogs) that you can work with
        for (final blog in blogs) {
          print('Blog ID: ${blog.id}');
          print('Image URL: ${blog.imageUrl}');
          print('Title: ${blog.title}');
        }
        print("Here Now Four");
        this.blogs = blogs;
        this.filteredBlogs = this
            .blogs
            .getRange(_startIndex, _startIndex + _batchSize)
            .toList();
        _startIndex = _startIndex + _batchSize;
      } else if (response.statusCode == 403) {
        throw Exception('Accessss denied');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        print("Here Now Five");
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in fetchData: $e");
      throw e;
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(5, (index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: double.infinity,
                    height: 200, // Set your desired height
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  height: 16, // Set your desired height
                  color: Colors.grey,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBlogList() {
    List<Blog> blogs = this.filteredBlogs;
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: AppBar(
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppConstants.appLogo,
                  height: 30,
                  width: 30,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  AppConstants.favoriteIcon,
                  color: Colors.red,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Favorites(blogs: this.blogs),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                loadMore();
              }
              return true;
            },
            child: ListView.builder(
              itemCount: blogs.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InsideScreen(
                                    blog: blogs[index],
                                    imageUrl: blogs[index].imageUrl ?? "",
                                  )),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          width: double.maxFinite,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // When the image is fully loaded, display it without shimmer.
                                } else {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: double.maxFinite,
                                      height: 200,
                                      color: Colors.white, // You can use any background color you like.
                                    ),
                                  );
                                }
                              },
                              blogs[index].imageUrl ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("In image");
                                return Image.asset(
                                  AppConstants.error,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        blogs[index].title!,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  loadMore() {
    try {
      if (_startIndex >= blogs.length) {
        return;
      }
      if (_startIndex + _batchSize > blogs.length) {
        this.filteredBlogs.addAll(this.blogs.getRange(_startIndex, blogs.length));
        _startIndex = blogs.length;
      } else {
        this.filteredBlogs.addAll(this.blogs.getRange(_startIndex, _startIndex + _batchSize));
        _startIndex = _startIndex + _batchSize;
      }
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }
}
