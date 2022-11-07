// ignore_for_file: prefer_const_constructors

import 'package:chat/pages/group_info.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/widgets/message_tile.dart';
import 'package:chat/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messagesController = TextEditingController();
  String admin = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatandAdmin();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, GroupInfo(
                groupId: widget.groupId,
                groupName: widget.groupName,
                adminName: admin,
              ));
            }, 
            icon: Icon(Icons.info),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Colors.grey[700],
              child: Row(children: [Expanded(child: TextFormField(
                controller: messagesController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                  border: InputBorder.none,
                    ),
                  )),
                  SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return MessageTile(
                  message: snapshot.data.docs[index]['message'], 
                  sender:snapshot.data.docs[index]['sender'], 
                  sentByMe: widget.userName == 
                      snapshot.data.docs[index]['sender'],
                );
              },
        )
        : Container();
      },
    );
  }
  sendMessage() {
    if(messagesController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': messagesController.text,
        'sender': widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messagesController.clear();
      });
    }
  }
}