import 'package:clubs_app/bindings.dart';
import 'package:clubs_app/generalLayout/generalLayoutCtr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../myUi.dart';
import '../styles.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgCol,
      child: GetBuilder<LayoutCtr>(builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 20,),
              Expanded(
                child: Container(
                  child:layCtr.allUsers.isNotEmpty? ListView.builder(
                    //  physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                        right: 0,
                        left: 0,
                      ),
                      //itemExtent: 100,// card height
                      itemCount: layCtr.allUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        ScUser usr = (layCtr.allUsers[index]);
                        return userCard(usr, index,tappable: true);
                       }
                       ):Center(child: Text('No Users to show',style: TextStyle(fontSize: 16)),),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
