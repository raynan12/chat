// ignore_for_file: prefer_const_constructors

import 'package:chat/helpers/helper_function.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = '';
  bool isJoined = false;
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Pesquisar',
          style: TextStyle(
            fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Pesquisar grupos...',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40)),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading 
              ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,),
                )
              :  groupList()
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if(searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
            setState(() {
              searchSnapshot = snapshot;
              isLoading = false;
              hasUserSearched = true;
            });
          });
    }
  }

  groupList() {
    return hasUserSearched
      ? ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context, index) {
          return groupTile(
            userName, 
            searchSnapshot!.docs[index]['groupId'], 
            searchSnapshot!.docs[index]['groupName'], 
            searchSnapshot!.docs[index]['admin'], 
          );
        },
      )
      : Container();
  }

  joinedOrNot(
    String userName, String groupId, String groupname, String admin) async {
      await DatabaseService(uid: user!.uid)
          .isUserJoined(groupname, groupId, userName)
          .then((value) {
            setState(() {
              isJoined = value;
            });
      });
    }

  Widget groupTile(
    String userName, String groupId, String groupName, String admin) {
      joinedOrNot(userName, groupId, groupName, admin);
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(groupName, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Admin: ${getName(admin)}'),
        trailing: InkWell(
          onTap: () async {
            await DatabaseService(uid: user!.uid)
                .toggleGroupJoin(groupId, userName, groupName);
            if(isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              showSnackBar(context, Colors.green, 'Entrou no grupo com sucesso');
              Future.delayed(Duration(seconds: 2), () {
                nextScreen(
                  context, 
                  ChatPage(
                    groupId: groupId, 
                    groupName: groupName, 
                    userName: userName,
                  ),
                );
              });
            } else {
              setState(() {
                isJoined = !isJoined;
                showSnackBar(context, Colors.red, 'Deixou o grupo $groupName');
              });
            }
          },
          child: isJoined
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1)
                ),
                padding: 
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Entrou',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor,
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Não entrou', style: TextStyle(color: Colors.white),),
            ),
        ),
      );
    }

}