
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( Home(),);
}
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  MyApp(),

    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final _firestore = FirebaseFirestore.instance;
  late String message;
  late String mail;

  void getMessages() async {
    final messages = await _firestore.collection('messages').get();
    for (var message in messages.docs) {
      print(message.data());
    }
  }
  void messageStream() async{
    await for( var snapshot in _firestore.collection('message').snapshots() ){
      for( var snapshot in snapshot.docs){
        print(snapshot);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
       home: Scaffold(
         appBar: AppBar(
           title: Text('Global Chat'),
         ),
         body:
         Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children:  [
             StreamBuilder<QuerySnapshot>(
                 stream: _firestore.collection('mess',).snapshots(),
                 builder: (context, AsyncSnapshot snapshot){
                   if(snapshot.hasData){
                     final messages = snapshot.data!.docs;
                     List<Text> messageWidgets = [];
                     for( var message in messages){
                        final messageText = message.data['text'];
                        final messageWidget = Text('$messageText');
                        messageWidgets.add(messageWidget);
                     }
                     return  Column(
                       children:
                         messageWidgets,
                     );
                   }

                 }
             ),
             Row(
               children: [
                 Expanded(
                 child:  TextField(
                    onChanged: (value){
                       message= value;
                    },
                   //textAlign: TextAlign.center,
                   decoration: InputDecoration(
                     hintText: 'Enter Message',

                   ),
                 ),
               ),
                 MaterialButton(
                   color: Colors.deepPurpleAccent ,
                   child: Text('Send'),
                     onPressed: (){
                          _firestore.collection('mess').add({
                            'text' : message,
                          });
                 }
                 )
                ]
             )
           ],
         ),
       ),
    );
  }
}
class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: loggedInUser.email == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}
