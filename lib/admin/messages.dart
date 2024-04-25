import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:clubs_app/bindings.dart';
import 'package:clubs_app/generalLayout/generalLayoutCtr.dart';
import 'package:clubs_app/models/club.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';

class ClubMessages extends StatefulWidget  {
  const ClubMessages({super.key});

  @override
  State<ClubMessages> createState() => _ClubMessagesState();
}

class _ClubMessagesState extends State<ClubMessages> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text(
        'Messages',style: TextStyle(
        fontWeight: FontWeight.w500,
        color: appBarTitleColor,

        ),

    ),
    bottom: appBarUnderline(),
          actions: [
            if(cUser.isAdmin) ...[
              //refresh
              GestureDetector(
                onTap: () {


                  layCtr.deleteMessages();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11.0),
                  child: Center(
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),

            ],
          ],
        ),
      body: Container(
        color: bgCol,
        child: GetBuilder<LayoutCtr>(
          dispose: (_){


            Future.delayed(const Duration(milliseconds: 100), () {
              layCtr.badgeCount=0;
              layCtr.update();
              layCtr.seenMessages = layCtr.messages.length;
              sharedPrefs!.setInt('${layCtr.selectedClub.id}',layCtr.seenMessages);
              print('## setInt seenMessages = ${layCtr.seenMessages} ');
              layCtr.selectClub(layCtr.selectedClub.id);
              sharedPrefs!.reload();
            });
          },
          builder:(ctr)=> Stack(
            children: [
              layCtr.messagesWidgets.isNotEmpty
                  ? SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Column(children: layCtr.messagesWidgets),
                      SizedBox(height: 90)
                    ],
                  )
              )
                  : Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 115.0),
                  child: Text(cUser.isAdmin? 'Send your first message' : 'No messages to show',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18
                    ),
                  ),
                ),
              ),
              ///send btn
              if(!cUser.isAdmin) Container(),
             if(cUser.isAdmin) MessageBar(
                onSend: (msg) {
                  print('## message: $msg');
                  layCtr.sendMessage(msg);
                },
                replyWidgetColor: Colors.black54,
                sendButtonColor: blueCol,
                messageBarColor: Colors.transparent,
                actions: [
                  InkWell(
                    child: Icon(
                      Icons.add,
                      color: blueCol,
                      size: 24,
                    ),
                    onTap: () {},
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: InkWell(
                      child: Icon(
                        Icons.camera_alt,
                        color: blueCol,
                        size: 24,
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
