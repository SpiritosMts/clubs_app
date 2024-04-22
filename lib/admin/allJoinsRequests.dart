import 'package:clubs_app/bindings.dart';
import 'package:clubs_app/generalLayout/generalLayoutCtr.dart';
import 'package:clubs_app/models/club.dart';
import 'package:clubs_app/models/request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../myUi.dart';
import '../styles.dart';

class AllJoinsRequests extends StatefulWidget {
  const AllJoinsRequests({super.key});

  @override
  State<AllJoinsRequests> createState() => _AllJoinsRequestsState();
}

class _AllJoinsRequestsState extends State<AllJoinsRequests> {
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
                  child:layCtr.allRequests.isNotEmpty? ListView.builder(
                    //  physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                        right: 0,
                        left: 0,
                      ),
                      //itemExtent: 100,// card height
                      itemCount: layCtr.allRequests.length,
                      itemBuilder: (BuildContext context, int index) {
                        JoinRequest clb = (layCtr.allRequests[index]);
                        return requestCard(clb, index,tappable: true,btnOnPress: (){

                        });
                      }
                  ):Center(child: Text('No requests to show',style: TextStyle(fontSize: 16)),),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
