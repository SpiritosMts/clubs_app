import 'package:clubs_app/bindings.dart';
import 'package:clubs_app/generalLayout/generalLayoutCtr.dart';
import 'package:clubs_app/models/club.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../myUi.dart';
import '../styles.dart';

class ClubsList extends StatefulWidget {
  const ClubsList({super.key});

  @override
  State<ClubsList> createState() => _ClubsListState();
}

class _ClubsListState extends State<ClubsList> {
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
                  child:layCtr.selectedClubs.isNotEmpty? ListView.builder(
                    //  physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                        right: 0,
                        left: 0,
                      ),
                      //itemExtent: 100,// card height
                      itemCount: layCtr.selectedClubs.length,
                      itemBuilder: (BuildContext context, int index) {
                        Club clb = (layCtr.selectedClubs[index]);
                        return clubCard(clb, index,tappable: true,btnOnPress: (){

                        });
                      }
                  ):Center(child: Text('No Clubs to show',style: TextStyle(fontSize: 16)),),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
