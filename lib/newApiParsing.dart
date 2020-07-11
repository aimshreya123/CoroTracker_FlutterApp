import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class NewsObject {
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String published;

  NewsObject(
      {this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.published});

  factory NewsObject.fromJson(Map<String, dynamic> json) {
    return NewsObject(
        author: json["author"],
        title: json["title"],
        description: json["description"],
        url: json["url"],
        urlToImage: json["urlToImage"],
        published: json["publishedAt"]);
  }
}

class MyNewsApp extends StatelessWidget {
  final String appTitle = "News API App";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber[400],
        primaryColorLight: Colors.blue[300],
        primaryColorDark: Colors.red[400],
        primaryColorBrightness: Brightness.dark,
      ),
      home: NewsHomePage(titleName: appTitle),
    );
  }
}

Future<List<NewsObject>> fetchNews(http.Client client) async {
  final newsURL =
      "http://newsapi.org/v2/everything?q=apple&from=2020-07-08&to=2020-07-08&sortBy=popularity&apiKey=0e9c0fa5ae1c471a8677099743999f7f";

  final response = await client.get(newsURL);
  return compute(parsesNews, response.body);
}

List<NewsObject> parsesNews(String response) {
  Map<String, dynamic> jsonData = jsonDecode(response);
  List newsList = jsonData["articles"];
  return newsList.map((json) => NewsObject.fromJson(json)).toList();
}

class NewsHomePage extends StatelessWidget {
  final String titleName;
  NewsHomePage({Key key, @required this.titleName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchNews(http.Client()),
        builder: (context, snapshot) {
          return snapshot.hasError
              ? Center(child: Text("Some Error: \n ${snapshot.error}"))
              : snapshot.hasData
                  ? NewsList(newsObjectList: snapshot.data)
                  : Center(
                      child: new CircularProgressIndicator(),
                    );
        },
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  final List<NewsObject> newsObjectList;
  NewsList({Key key, this.newsObjectList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: newsObjectList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.network(newsObjectList[index].urlToImage),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      newsObjectList[index].title,
                      style: TextStyle(fontSize: 26, color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Author: ${newsObjectList[index].author}",
                      style: TextStyle(fontSize: 22, color: Colors.black45),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Published: ${newsObjectList[index].published}",
                      style: TextStyle(fontSize: 22, color: Colors.black45),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Description: \n${newsObjectList[index].description}",
                      softWrap: true,
                      style: TextStyle(fontSize: 22, color: Colors.black45),
                    ),
                  ],
                ),
              ),
            ),
            onLongPress: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompleteNews(
                      newsUrl: newsObjectList[index].url,
                    ),
                  ));
            },
          );
        });
  }
}

class CompleteNews extends StatelessWidget {
  final String newsUrl;
  CompleteNews({Key key, this.newsUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Page"),
      ),
      body: WebView(
        initialUrl: newsUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
