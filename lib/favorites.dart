import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_project/constants.dart';
import 'package:news_project/inside_screen.dart';
import 'package:news_project/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Favorites extends StatefulWidget {
  final List<Blog> blogs;

  const Favorites({
    Key? key,
    required this.blogs,
  }) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Blog> favoriteBlogs = [];
  bool isLoading = true; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    loadFavoriteBlogs();
  }

  Future<void> loadFavoriteBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteBlogIds = prefs.getStringList('favoriteBlogs') ?? [];

    try {
      final List<Blog> allBlogs = widget.blogs; // Call the fetchData function
      final List<Blog> favorites =
          allBlogs.where((blog) => favoriteBlogIds.contains(blog.id)).toList();

      setState(() {
        favoriteBlogs = favorites;
        isLoading = false; // Set loading state to false when done loading
      });
    } catch (e) {
      if (e is Exception) {
        if (e.toString().contains("403")) {
          // Handle the 403 condition here
          setState(() {
            isLoading = false; // Set loading state to false
            favoriteBlogs = []; // Clear the list of favorite blogs
          });
          return; // Exit the function to avoid further processing
        }
      }
      // Handle other errors here
      print('Error fetching blogs: $e');
    }
  }

  void updateFavoriteStatus() {
    // Reload favorite blogs or update the favoriteBlogs list
    loadFavoriteBlogs();
  }

  @override
  Widget build(BuildContext context) {
    print('Favorites screen is rebuilding.'); // Add this line
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 10,
                ),
                _buildAppBar(),
                SizedBox(
                  height: 20,
                ),
                isLoading
                    ? _buildShimmerLoading()
                    : favoriteBlogs.isEmpty
                        ? _buildEmptyList()
                        : _buildFavoritesList(),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildEmptyList() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppConstants.emptyBox,
          height: 200,width: 200,
          ),
          SizedBox(height: 20,),
          Text(AppConstants.emptyText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          ),
        ],
      ),
    );
  }

  Flexible _buildFavoritesList() {
    return Flexible(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: favoriteBlogs.length,
        itemBuilder: (BuildContext context, int index) {
          final blog = favoriteBlogs[index];
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsideScreen(
                              blog:
                                  blog, // Pass the selected Blog object to InsideScreen
                              imageUrl: blog.imageUrl ?? "",
                              onFavoriteStatusChanged:
                                  updateFavoriteStatus, // Pass the callback function
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  blog.imageUrl.toString(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  _showAlertDialog(favoriteBlogs[
                                      index]); // Pass the blog object
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  margin: EdgeInsets.only(right: 10, top: 10),
                                  child: Icon(
                                    AppConstants.favorite_rounded,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      blog.title.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Container _buildAppBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: AppBar(
        centerTitle: true,
        title: Text(
          AppConstants.favoritesText,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(Blog blog) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppConstants.removeBlogText),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(AppConstants.sureText),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                TextButton(
                  child: const Text(AppConstants.noText),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(AppConstants.yesText),
                  onPressed: () async {
                    removeBlogFromFavorites(
                        blog); // Remove the blog from favorites
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> removeBlogFromFavorites(Blog blog) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteBlogIds = prefs.getStringList('favoriteBlogs') ?? [];

    setState(() {
      // Remove the blog's ID from the list of favorite blogs
      favoriteBlogIds.remove(blog.id);

      // Update the favoriteBlogs list by filtering out the removed blog
      favoriteBlogs = favoriteBlogs.where((b) => b.id != blog.id).toList();

      // Save the updated list of favorite blog IDs to SharedPreferences
      prefs.setStringList('favoriteBlogs', favoriteBlogIds);
    });
  }

  Widget _buildShimmerLoading() {
    return Center(
      child: Column(
        children: List.generate(2, (index) {
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
}
