import 'package:avatar_glow/avatar_glow.dart';
import 'package:clubs_app/admin/clubUsersList.dart';
import 'package:clubs_app/generalLayout/generalLayoutCtr.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../bindings.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';


class ClubDetails extends StatefulWidget {
  const ClubDetails({super.key});

  @override
  State<ClubDetails> createState() => _ClubDetailsState();
}

class _ClubDetailsState extends State<ClubDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text(
          'Club Info',style: TextStyle(
          fontWeight: FontWeight.w500,
          color: appBarTitleColor,
        ),
        ),
        bottom: appBarUnderline(),
        leading:IconButton(
          icon: Icon(Icons.group,color: appBarNotificationBellColor,),
          onPressed: () {
            Get.to(()=>ClubUsersList());

          },
        ) ,
        actions: [
         if(cUser.isAdmin) GestureDetector(
            onTap: () {
              showAnimDialog(layCtr.addEventDialog());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11.0),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: appBarButtonsCol,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Container(
        color: bgCol,
        child: GetBuilder<LayoutCtr>(builder: (_) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  layCtr.selectedClub.name, // Replace with actual name
                  style: TextStyle(
                    color: normalTextCol,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: AvatarGlow(
                          child: RandomAvatar('saytoonz', trBackground: false, height: 150, width: 150,),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Members:'.tr,
                              style: TextStyle(
                                fontSize: 23.0,
                                color: normalTextCol.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            RichText(
                              textAlign: TextAlign.start,
                              softWrap: true,
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '${layCtr.selectedClub.members.length}',
                                  style: GoogleFonts.almarai(
                                    fontSize: 26.sp,
                                    color: blueCol.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                    text: '  Pts',
                                    style: GoogleFonts.almarai(
                                      height: 1,
                                      textStyle:
                                      const TextStyle(color: transparentTextCol, fontSize: 20, fontWeight: FontWeight.w500),
                                    )),
                              ]),
                            ),
                            SizedBox(height: 5.0),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
                ),

                CustomDivider(
                  text: '  Events  ',
                ),
                SizedBox(height: 20,),
                layCtr.usersOfClub(layCtr.selectedClub).isEmpty?Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(child: Text('No events to show', style: TextStyle(
                      fontSize: 15
                    ),),)): Expanded(
                  child: Container(
                    child: ListView.builder(
                      //  physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 20,
                          right: 0,
                          left: 0,
                        ),
                        //itemExtent: 100,// card height
                        itemCount: layCtr.selectedEvents.length,
                        itemBuilder: (BuildContext context, int index) {
                          ClubEvent ev = (layCtr.selectedEvents[index]);
                          return eventCard(ev, index);
                        }),
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

class CustomDivider extends StatelessWidget {
  final String text;

  const CustomDivider({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.orange,
            height: 3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.orange,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.orange,
            height: 3,
          ),
        ),
      ],
    );
  }
}
