// ignore_for_file: prefer_const_constructors

import 'package:chat/helpers/helper_function.dart';
import 'package:chat/pages/auth/login_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/search_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/widgets/group_tile.dart';
import 'package:chat/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String email = '';
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_")+1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  // gettingUserData() async {
  //   await HelperFunctions.getUserEmailFromSF().then((value) {
  //     setState(() {
  //       email = value!;
  //     });
  //   });
  //   await HelperFunctions.getUserNameFromSF().then((val) {
  //     setState(() {
  //       userName = val!;
  //     });
  //   });

  //   await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //           .getUserGroups()
  //           .then((snapshot) {
  //             setState(() {
  //              groups = snapshot;
  //             });
  //           });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, SearchPage());
            }, 
            icon: Icon(
              Icons.search,
            )),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Grupos',
          style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                'Grupos', 
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                  context, 
                  ProfilePage(
                    userName: userName,
                    email: email,
                  ));
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                'Perfil', 
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Sair'),
                      content: Text('Tem certeza que deseja sair?'),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                          }, 
                          icon: Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),

                      ],
                    );
                  },
                );

                // authService.signOut().whenComplete(() {
                //   nextScreenReplace(context, LoginPage());
                // });
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Sair', 
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
          return AlertDialog(
            title: Text(
              'Criar um grupo',
              textAlign: TextAlign.left,            
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true
                  ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                  )
                  : TextField(
                    onChanged: (val) {
                      setState(() {
                        groupName = val;
                      });
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(20)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red),
                        borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor),
                child: Text('CANCELAR'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if(groupName != '') {
                    setState(() {
                      _isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid) 
                        .createGroup(userName, 
                            FirebaseAuth.instance.currentUser!.uid, groupName)
                        .whenComplete(() {
                          _isLoading = false;
                        });
                    Navigator.of(context).pop();
                    showSnackBar(
                      context, Colors.green, 'Grupo criado com sucesso');
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor),
                child: Text('CRIAR'),
              ),
              ],
            );
          })
        );
      },
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data['groups'] != null) {
            if(snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reversedIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                    groupId: getId(snapshot.data['groups'][reversedIndex]), 
                    groupName: getName(snapshot.data['groups'][reversedIndex]), 
                    userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          } 
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle, 
              color: Colors.grey[700], 
              size: 75,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Você não entrou em nenhum grupo, toque no ícone adicionar para criar um grupo ou também pesquise no botão de pesquisa superior.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}