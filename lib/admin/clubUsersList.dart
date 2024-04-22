import 'package:clubs_app/bindings.dart';
import 'package:clubs_app/generalLayout/generalLayoutCtr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../myUi.dart';
import '../styles.dart';

class ClubUsersList extends StatefulWidget {
  const ClubUsersList({super.key});

  @override
  State<ClubUsersList> createState() => _ClubUsersListState();
}

class _ClubUsersListState extends State<ClubUsersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text(
          'Members (${layCtr.selectedUsers.length})',style: TextStyle(
          fontWeight: FontWeight.w500,
          color: appBarTitleColor,
        ),
        ),
        bottom: appBarUnderline(),

      ),

      body: Container(
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
                    child:layCtr.selectedUsers.isNotEmpty? ListView.builder(
                      //  physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 20,
                          right: 0,
                          left: 0,
                        ),
                        //itemExtent: 100,// card height
                        itemCount: layCtr.selectedUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          ScUser usr = (layCtr.selectedUsers[index]);
                          return userCard(usr, index,tappable: true);
                         }
                         ):Center(child: Text('No Users to show',style: TextStyle(fontSize: 16)),),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
