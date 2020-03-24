import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'messages.dart';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mann_ki_baat/componenets.dart';

final _fireStore = Firestore.instance;

class ChatPage extends StatefulWidget {
  ChatPage({this.myId, this.otherId, this.otherUserName, this.imageUrlOther});
  final String myId;
  final String otherId;
  final String otherUserName;
  final String imageUrlOther;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageTextController = TextEditingController();
  String messageText;
  String chatID;

  @override
  void dispose() {
    _fireStore.collection('users').document(widget.myId).updateData({
      'isAvailable': 0,
      'isChatting': 0,
    });

    deleteChatSession(); //to delete the current chat session after it has been deleted

    _fireStore.collection('users').document(widget.otherId).updateData({
      'isAvailable':
          0, // if current user has left then other user's chatting session has also ended'
      'isChatting': 0,
    });

    super.dispose();
  }

  @override
  void initState() {
    _fireStore.collection('users').document(widget.myId).updateData({
      'isChatting': 1,
      'isAvailable': 0,
    });

    createChatSession();

    super.initState();
  }

  Widget getConnectedUserAppBar() {
    String _userName = widget.otherUserName;
    
    return Row(children: <Widget>[
      CircleAvatar(
          child: widget.imageUrlOther == null
              ? DefaultAvatar(username: widget.otherUserName)
              : Image.network(widget.imageUrlOther)),
      Text('⚡️Chat with ${_userName.substring(0,_userName.indexOf(' '))}')
    ]);
  }

  void deleteChatSession() async {
    String chatSessionID = generateUniqueSessionID();
    await _fireStore
        .collection('chat_session')
        .document(chatSessionID)
        .delete();
  }

  void createChatSession() async {
    //TODO: try to create common chat session for both uid

    String chatSessionID = generateUniqueSessionID();

    chatID = chatSessionID;

    final QuerySnapshot result = await Firestore.instance
        .collection('chat_session')
        .where('id', isEqualTo: chatSessionID)
        .getDocuments();

    final List<DocumentSnapshot> documents = result.documents;

    if (documents.length == 0) {
      //Chat Session Has not been created
      _fireStore.collection('chat_session').document(chatSessionID).setData({
        'id': chatSessionID,
        'messages': [
          {
            'messageText': 'Connected with ${widget.otherUserName}',
            'senderID': widget.otherId,
            'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch
          },
        ]
      });
    } else {
      //Chat Session has been created
    }
  }

  String generateUniqueSessionID() {
    String me = widget.myId;
    String other = widget.otherId;
    if (me.compareTo(other) < 1) {
      return (me + other);
    } else {
      return (other + me);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getConnectedUserAppBar(),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(chatID,widget.myId),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      var list = List<Map<dynamic, dynamic>>();

                      list.add({
                        'messageText': messageText,
                        'senderID': widget.myId,
                        'timestamp':
                            DateTime.now().toUtc().millisecondsSinceEpoch
                      });

                      String chatSessionID = generateUniqueSessionID();
                      _fireStore
                          .collection('chat_session')
                          .document(chatSessionID)
                          .updateData(
                              {'messages': FieldValue.arrayUnion(list)});

                      setState(() {
                        messageList.add(Message(
                            messageText: messageText, senderID: widget.myId));
                      
                      messageTextController.clear();
                      });
                      // implemented send functionality to backend
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class MessagesStream extends StatelessWidget {
  MessagesStream(this.chatId,this.myId);
  String chatId;
  String myId;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('chat_session').document(chatId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        
        final messages = List.from(snapshot.data.data['messages']);
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {

          final messageText = message['messageText'];
          final messageSender = message['senderID'];

          final messageBubble =
              MessageBubble(senderID: messageSender, text: messageText, myId: myId);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget { 
  MessageBubble({this.senderID, this.text, this.myId});

  final String senderID;
  final String text;
  final String myId;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Bubble(
          style: senderID == myId ? styleMe : styleSomebody,
          child: Text(
            text,
            style: TextStyle(fontSize: 15.0),
          ),
        )
    );
  }
}

