import 'package:flutter/material.dart';
import 'dart:async';

import 'package:grpc/grpc.dart';

import 'package:hunger/src/generated/quiz.pb.dart';
import 'package:hunger/src/generated/quiz.pbgrpc.dart';

Future<QuizerClient> connect(String sock) async {
  List ipAndPort = sock.split(':');
  final channel = new ClientChannel(
      ipAndPort[0],
      port: int.parse(ipAndPort[1]),
      options: const ChannelOptions(
          credentials: const ChannelCredentials.insecure()));
  return new QuizerClient(channel);
}

Future<String> getQuiz(String quizName, client) async {
  if (client == null) {
    return 'Connect first';
  }

  try {
    final response = await client.getQuiz(new QuizRequest()..message = quizName);
    print('Quiz client received: ${response.message}');
    return response.message;
  } catch (e) {
    print('Caught error: $e');
    return e.message;
  }
}

Future<String> setQuiz(String quizName, client) async {
  if (client == null) {
    return 'Connect first';
  }

  try {
    final response = await client.setQuiz(new QuizRequest()..message = quizName);
    print('Quiz client received: ${response.message}');
    return response.message;
  } catch (e) {
    print('Caught error: $e');
    return e.message;
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunger for Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Quiz main'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _quiz = '';
  QuizerClient _client;
  final quizController = TextEditingController();
  final serverController = TextEditingController();

  Future<void> _connect(ctx) async {
    _client = await connect(ctx);
    setState(() {
      _quiz = 'Connected';
    });
  }

  Future<void> _getQuiz(ctx) async {
    String response = await getQuiz(ctx, _client);
    setState(() {
      _quiz = response;
    });
  }

  Future<void> _setQuiz(ctx) async {
    String response = await setQuiz(ctx, _client);
    setState(() {
      _quiz = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create new Quiz'),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
		    controller: quizController,
                    decoration: InputDecoration(
                      labelText: 'Get Quiz by name',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      color: Colors.indigoAccent,
                      child: Text('Get'),
                      onPressed: () => _getQuiz(quizController.text),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      color: Colors.indigoAccent,
                      child: Text('Set'),
                      onPressed: () => _setQuiz(quizController.text),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
		    '$_quiz',
       		    style: new TextStyle(
       		      fontSize: 20.0,
       		      color: Colors.yellow,
   		    ),
	        ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
		    controller: serverController,
                    decoration: InputDecoration(
                      labelText: 'Connect to IP',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      color: Colors.indigoAccent,
                      child: Text('connect'),
                      onPressed: () => _connect(serverController.text),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
