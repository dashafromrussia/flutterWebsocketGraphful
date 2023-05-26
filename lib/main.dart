import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert' as convert;
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
void main()async{
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Websockets and GraphQL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String textData ='';
  List<Map<String,dynamic>> datas =[];
  final String name = 'Dima';
  final int age = 34;
  IO.Socket socket = IO.io('http://192.168.0.123:5000',
      IO.OptionBuilder()
          .setTransports(['websocket']).build());
  void connectAndListen(){
    socket.onConnect((_) {
      print('connect');
      //socket.emit('msg', 'test');
    });
    socket.emit('select','');
    socket.on('event',(data){
      print(data);
      (data as List).forEach((element) {
        datas.add(element as Map<String,dynamic>);
      });
      datas = datas.reversed.toList();
      setState(() {
      });
    });
    socket.on('eventt', (data){
      datas.add(data as Map<String,dynamic>);
      setState(() {

      });
      datas = datas.reversed.toList();
      print(datas);
    });
    socket.onDisconnect((_) => print('disconnect'));

  }
  @override
  void initState() {
    super.initState();
    connectAndListen();
    print('cucucu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Websockets and GraphQL'),
        ),
        body:Center(child:Container(
          padding: EdgeInsets.all(20),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Graphql",style: TextStyle(fontSize: 20),),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(onPressed:()async{
                    HttpLink httpLink = HttpLink("http://192.168.0.123:5000/graphql");
                    GraphQLClient qlClient = GraphQLClient(
                      link: httpLink,
                      cache: GraphQLCache(
                        store:
                        HiveStore(),
                      ),
                    );
                    QueryResult queryResult = await qlClient.query(
                      QueryOptions(
                        document: gql(
                          """mutation{
                        createUser(input:{
                       username:"$name",age:$age
                          }){
                           id
                           username
                           age
                           }
                            }
                           """,
                        ),
                      ),
                    );
                    print(queryResult.data);
                  }, child: Text("+add user")),
                  ElevatedButton(onPressed:()async{
                    HttpLink httpLink = HttpLink("http://192.168.0.123:5000/graphql");
                    GraphQLClient qlClient = GraphQLClient(
                      link: httpLink,
                      cache: GraphQLCache(
                        store:
                        HiveStore(),
                      ),
                    );
                    QueryResult queryResult = await qlClient.query(
                      QueryOptions(
                        document: gql(
                          """query{
                               getAllUsers{
                               username
                               age
                           }
                           }
                           """,
                        ),
                      ),
                    );
                    print(queryResult.data);
                  }, child: Text("+getAllUsers")),
                  ElevatedButton(onPressed:()async{
                    HttpLink httpLink = HttpLink("http://192.168.0.123:5000/graphql");
                    GraphQLClient qlClient = GraphQLClient(
                      link: httpLink,
                      cache: GraphQLCache(
                        store:
                        HiveStore(),
                      ),
                    );
                    QueryResult queryResult = await qlClient.query(
                      QueryOptions(
                        document: gql(
                          """query{
                                getUser(id:1){
                               username
                               age
                              }
                                }""",
                        ),
                      ),
                    );
                    print(queryResult.data);
                  }, child: Text("+getOneUser")),
                ],
              ),
              const SizedBox(height: 10,),
              const Text("Websockets",style: TextStyle(fontSize: 20),),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child:Container(child:TextField(
                      onSubmitted: (text) {
                        print("onSubmitted");
                        print("Введенный текст: $text");
                      },
                      onChanged: (text) {
                        setState(() {
                          textData = text;
                        });
                        print("Введенный текст: $text");
                      }),width: 400,))  ,
                  const SizedBox(width: 10,),
                  ElevatedButton(onPressed:(){
                    socket.emit('emitev',textData);
                  }, child: Text("+add todo")),
                ],
              ),
              SizedBox(height: 50,),
              Expanded(child:Center(child:ListView.builder(
                itemCount: datas.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color:Colors.blueAccent,
                        borderRadius:BorderRadius.all(Radius.circular(5)) ,
                        border: Border.all(color: Colors.blueAccent,)
                    ),
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(datas[index]["name"].toString(),style: TextStyle(color: Colors.white,fontSize: 15),),
                        const SizedBox(height: 5,),
                        Text(datas[index]["mess"].toString(),style: TextStyle(color: Colors.white,fontSize: 20),),
                      ],
                    )
                    ,
                  ) ;
                },
              ),))
            ],
          ),))
    );
  }
}
