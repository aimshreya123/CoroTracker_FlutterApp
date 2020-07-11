import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:async';

Future<List<Statewise>> fetchCases(http.Client client) async{

  final url = "https://api.covid19india.org/data.json";
  // await -> do not execute the function below till time we do not get the data from http client request
  final response = await client.get(url);

  // Here, compute function will execute parseNews function in the background as an ISOLATE
  return compute(parseCases, response.body); //response.body -> will be our JSON Data
}

List<Statewise> parseCases(String responseBody) {

  Map<String, dynamic> jsonData = jsonDecode(responseBody);

  List statewiseData = jsonData["statewise"];

  return statewiseData.map<Statewise>((json) => Statewise.fromJson(json)).toList();

}

class Statewise{
  String confirmed;
  String active;
  String deaths;
  String recovered;
  String stateName;
  String updateTime;
  String notes;

  Statewise({this.active, this.confirmed, this.deaths, this.recovered, this.stateName, this.updateTime, this.notes});

  factory Statewise.fromJson(Map<String, dynamic> json){
    return Statewise(
      confirmed: json["confirmed"],
      active: json["active"],
      deaths: json['deaths'],
      recovered: json["recovered"],
      stateName: json["state"],
      updateTime: json["lastupdatedtime"],
      notes: json["statenotes"],
    );
  }
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Corona Tracker App",
        home: HomePage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
    ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Corona Tracker App"),
      ),
      body: FutureBuilder<List<Statewise>>(
        future: fetchCases(http.Client()),
        builder: (context, snapshot) {
          if(snapshot.hasError) print("Some Error ${snapshot.error}");
          return snapshot.hasData ? StatewiseCases(cases: snapshot.data) : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}



class StatewiseCases extends StatelessWidget {

  final List<Statewise> cases;
  const StatewiseCases({Key key, this.cases}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cases.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(12),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cases[index].stateName,
                  style: TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Cinzel' ),),
                Text("  Confirmed : "+cases[index].confirmed, style: TextStyle(fontSize: 18,color: Colors.black),),
                Text("  Active : "+cases[index].active, style: TextStyle(fontSize: 18,color: Colors.black),),
                Text("  Deaths : "+cases[index].deaths, style: TextStyle(fontSize: 18,color: Colors.black),),
                Text("  Recovered : "+cases[index].recovered, style: TextStyle(fontSize: 18,color: Colors.black),),
                Text("\n  LAST UPDATED : "+cases[index].updateTime, style: TextStyle(fontSize: 16,color: Colors.black45),),

              ],
            ),
          ),
        );
      },
    );
  }
}



