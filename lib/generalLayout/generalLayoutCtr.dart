import 'dart:async';
import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubs_app/models/club.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../main.dart';
import '../admin/clubDetails.dart';
import '../bindings.dart';
import '../firebaseVoids.dart';
import '../models/event.dart';
import '../models/request.dart';
import '../models/user.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';
import 'package:uuid/uuid.dart';

class LayoutCtr extends GetxController {
  String appBarText ='';//appbar title
  List<Widget> appBarBtns=[];

  @override
  onInit() {
    super.onInit();
    print('## ## init LayoutCtr');
    Future.delayed(const Duration(milliseconds: 50), ()  async {
      refreshAll();

    });
  }
  void refreshAll() async {
    // Execute all refresh functions concurrently
    await Future.wait([
      refreshUsers(),
      refreshRequests(),
      refreshClubs(),
    ]);
    onScreenSelected(0);

    update();
  }
  /// *************************************************************************************

  updateAppbar({String? title,List<Widget>? btns}){
    if(title!=null) appBarText = title;
    if(btns!=null) appBarBtns=btns;
    update();
  }
  onScreenSelected(int index){
    switch (index) {

      case 0:
        updateAppbar(title:cUser.isAdmin? 'All Clubs':'My Clubs',btns:cUser.isAdmin? [
          GestureDetector(
          onTap: () {
            refreshAll();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11.0),
            child: Center(
              child: Icon(
                Icons.refresh,
                color: appBarButtonsCol,
              ),
            ),
          ),
        ),
          GestureDetector(
            onTap: () {
              showAnimDialog(addClubDialog());

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
        ]:[
          GestureDetector(
            onTap: () {
              refreshClubs();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11.0),
              child: Center(
                child: Icon(
                  Icons.refresh,
                  color: appBarButtonsCol,
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(cUser.name,style: TextStyle(color: blueCol),),
              ),
            ],
          )
        ]);
        if(!cUser.isAdmin){
          selectedClubs = myClubs;
        }else{
          selectedClubs = allClubs;
        }

        update();
        break;

      case 1:
        updateAppbar(title:cUser.isAdmin? 'Join Requests':'Other Clubs',btns: []);
        if(!cUser.isAdmin){
          selectedClubs = otherClubs;
        }
        update();

        break;

      case 2:
        updateAppbar(title:cUser.isAdmin? 'All Users':'My Info',btns: cUser.isAdmin? []:[]);
        update();

        break;




    }
    print('## selected screen ($index) selectedClubs (${selectedClubs.length})');
    print('## all clubs (${allClubs.length}) // my clubs (${myClubs.length}) // other clubs (${otherClubs.length})');


  }
  /// *************************************************************************************


  //event +
  GlobalKey<FormState> addClubKey = GlobalKey<FormState>();
  final newClubNameTec = TextEditingController();
  final newClubDescTec = TextEditingController();
  PickedFile? newItemImage;
  deleteImage() {
    newItemImage = null;
    update();
  }
  updateImage(image){
    if(image != null){
      newItemImage = image!;
      update();
    }
  }

  //club +
  GlobalKey<FormState> addEventKey = GlobalKey<FormState>();
  final newEventTitleTec = TextEditingController();
  final newEventDescTec = TextEditingController();


  List<Club> selectedClubs = [];
  Club selectedClub=Club();
  List<ClubEvent> selectedEvents = [];
  List<ScUser> selectedUsers = [];
  selectClub(clubID){
    sharedPrefs!.reload();

    for (var club in allClubs) {
      if (club.id == clubID) {
        selectedClub = club;
      }
    }
    layCtr.seenMessages = sharedPrefs!.getInt('${layCtr.selectedClub.id}')??0;
    print('## getInt seenMessages = ${layCtr.seenMessages}');

    selectedEvents = selectedClub.events.reversed.toList();
    selectedUsers = usersOfClub(layCtr.selectedClub);
    print('## selected club <${clubID}>');
    update();

  }

  List<ScUser> allUsers =[];
  List<Club> allClubs =[];
  List<JoinRequest> allRequests =[];

  List<Club> myClubs =[];
  List<Club> otherClubs =[];

  Future<void> refreshUsers() async {
    allUsers = await getAlldocsModelsFromFb<ScUser>(
        true, usersColl, (json) => ScUser.fromJson(json),
        localKey: '');
    update();
  }
  List<ScUser> usersOfClub(Club club){
    List studentIDs = club.members;
    List<ScUser> list =[];


    for (ScUser usr in allUsers) {
      // Check if the user's ID is in the studentIDs list
      if (studentIDs.contains(usr.id)) {
        // Add user to the list
        list.add(usr);
      }
    }

    return list;
  }




  ///event
  addEventDialog() {
    return AlertDialog(
      backgroundColor: dialogBgCol,
      title: Text('Add New Event',
        style: TextStyle(
          color: dialogTitleCol,
        ),),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      content: Builder(
        builder: (context) {

          return SizedBox(
            //height: 100.h / 1.7,
            width: 100.w,
            child: AddEvDia(),
          );
        },
      ),
    );
  }
  addEventToDB() async {
    try{

    String specificID = Uuid().v1();

    /// add the image
    String itemImageUrl = await uploadOneImgToFb('clubs/${selectedClub.name}-${selectedClub.id}/events', newItemImage);

   String eventDate = todayToString(showHoursNminutes: true);
    ClubEvent newEvent = ClubEvent(
      title: newEventTitleTec.text,
      desc: newEventDescTec.text,
      date: eventDate,
       imageUrl: itemImageUrl,
       id: specificID,

    );


      /// add to map
      addToMap(
          coll: clubsColl,
          docID: selectedClub.id,
          fieldMapName: 'events',
          mapToAdd: newEvent.toJson(),

      );


      Get.back(); //hide loading
    layCtr.sendMessage('New Event "${newEventTitleTec.text}" has been added , Date : ${eventDate}');

    newEventDescTec.clear();
      newEventTitleTec.clear();
    newItemImage = null;

    refreshThisClub();
    }catch  (err){
      print('## cant create event  : $err');
    }
  }
  Future<void> deleteEvent(id)async{
    deleteFromMap(coll: clubsColl,docID: selectedClub.id,fieldMapName: 'events',targetInvID: id);
  }

  ///clubs
  refreshThisClub(){
    refreshClubs().then((value) {
      selectClub(selectedClub.id);
      update();
    });
    update();
  }
  Future<void> refreshClubs() async {
    print('## refreshing clubs ...');

    allClubs = await getAlldocsModelsFromFb<Club>(
        true, clubsColl, (json) => Club.fromJson(json),
        localKey: '');
    selectedClubs.clear();
    myClubs.clear();
    otherClubs.clear();
    for (Club club in allClubs) {
      if (club.members.contains(cUser.id)) {
        // user is in this club
        myClubs.add(club);
      } else {
        // user is NOT in this club
        otherClubs.add(club);
      }
    }

    if(!cUser.isAdmin){
      selectedClubs = myClubs;
    }else{
      selectedClubs = allClubs;

    }
    update();
    print('## all clubs (${allClubs.length}) // my clubs (${myClubs.length}) // other clubs (${otherClubs.length})');
  }
  addClubDialog() {
    return AlertDialog(
      backgroundColor: dialogBgCol,
      title: Text('Add New Club',
        style: TextStyle(
          color: dialogTitleCol,
        ),),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Form(
          key: addClubKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 20,),

              /// components

              customTextField(
                textInputType: TextInputType.text,
                controller: newClubNameTec,
                labelText: 'Name'.tr,
                hintText: ''.tr,
                icon: Icons.title,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "name can't be empty".tr;
                  }


                  return null;

                },
              ),
              SizedBox(height: 18,),
              customTextField(
                textInputType: TextInputType.text,
                controller: newClubDescTec,
                labelText: 'Description'.tr,
                hintText: ''.tr,
                icon: Icons.description,
                validator: (value) {

                  return null;

                },
              ),
              SizedBox(height: 18,),






              /// buttons
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //cancel
                    TextButton(
                      style: borderBtnStyle(),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(color: dialogBtnCancelTextCol),
                      ),
                    ),
                    //add
                    TextButton(
                      style: filledBtnStyle(),
                      onPressed: () async {
                        if(addClubKey.currentState!.validate()){
                          addClubToDB();
                        }
                      },
                      child: Text(
                        "Add".tr,
                        style: TextStyle(color: dialogBtnOkTextCol ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  addClubToDB() async {
    Club newClub = Club(
      name: newClubNameTec.text,
      desc: newClubDescTec.text,
      createdTime: todayToString(showHoursNminutes: true),

    );
    try{
      String specificID = Uuid().v1();

      var value = await addDocument(
        specificID: specificID,
        fieldsMap: newClub.toJson(),
        coll: clubsColl,

      );
      Get.back(); //hide loading
      newClubDescTec.clear();
      newClubNameTec.clear();
      refreshClubs();
    }catch  (err){
      print('## cant create club  : $err');
    }
  }
  openClub(){
    Get.to(()=>ClubDetails());
  }
  Future<bool> alreadySentReq() async {

    QuerySnapshot querySnapshot = await requestsColl
        .where('studentID', isEqualTo: cUser.id)  // Check for the field 'studentID' with value '123'
        .where('clubToJoinID', isEqualTo: selectedClub.id)  // Check for the field 'clubToJoinID' with value '456'
        .get();

    // Check if there are any documents that match the conditions
    if (querySnapshot.docs.isNotEmpty) {
      print('Document found with specified conditions');

      return true;
      // You can access the documents here and process them further
      for (var doc in querySnapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
      }
    } else {
      print('No document found with specified conditions');
      return false;

    }
  }
/// req
  Future<void> refreshRequests() async {
    allRequests = await getAlldocsModelsFromFb<JoinRequest>(
        true, requestsColl, (json) => JoinRequest.fromJson(json),
        localKey: '');
    update();
  }
  addRequest()async{
    if(myClubs.contains(selectedClub.id)){
      showTos('You are already a member in this club',color: Colors.black87);
      return;
    }

    if(await alreadySentReq()){
      showTos('You already sent a join request... Please wait for approvement',color: Colors.black87);
      return;
    }

    bool accept = false;
     accept = await showNoHeader(txt: 'are you sure you want to request to join "${selectedClub.name}" ?',btnOkText: 'Send Request');
    if(!accept) {
      return;
    }


    JoinRequest newReq = JoinRequest(
      clubToJoinID: selectedClub.id,
      clubToJoinName: selectedClub.name,
      studentID: cUser.id,
      studentName: cUser.name,
      date: todayToString(showHoursNminutes: true),


    );
    try{
      String specificID = Uuid().v1();
      var value = await addDocument(
        specificID: specificID,
        fieldsMap: newReq.toJson(),
        coll: requestsColl,

      );
      Get.back(); //hide loading
      showTos('Your join request has been sent!',color: Colors.green);

    }catch  (err){
      print('## cant create request  : $err');
    }

  }
  acceptReq(JoinRequest req){
    // add user id to club members List of members IDs
    deleteDoc(docID: req.id,coll: requestsColl,success: (){//delete the request
      addElementsToList([req.studentID],'members',req.clubToJoinID,clubsCollName,canAddExistingElements: false);
      refreshThisClub();
    });
  }
  removeFromClub(ScUser usr) async {
    bool accept = await showNoHeader(txt: 'are you sure you want to remove ${usr.name} from ${selectedClub.name} club ?',btnOkText: 'Remove');
    if(!accept) return;
    // add user id to club members List of members IDs
      removeElementsFromList([usr.id],'members',selectedClub.id,clubsCollName).then((value) {
        refreshThisClub();

      });

  }
  declineReq(JoinRequest req){
    deleteDoc(docID: req.id,coll: requestsColl,success: (){
      refreshThisClub();

    });
  }


  ///MESSAGING
  late  StreamSubscription<QuerySnapshot> streamSub;
  Map<String, dynamic> messages = {};
  List<Widget> messagesWidgets = [];
  int seenMessages = 0;
  int badgeCount = 0;





  Future<void> sendMessage(String msg) async {
    if (msg.isNotEmpty) {
      clubsColl.doc(selectedClub.id ).get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          //get existing raters of garage
          Map<String, dynamic> messages = documentSnapshot.get('messages');

          Map<String, dynamic> msgDetails = {
            'msg': msg,
            'sender': authCtr.cUser.name,
            'time': todayToString(showHoursNminutes: true),
          };
          messages[messages.length.toString()] = msgDetails;

          //add raters again map to cloud
          await clubsColl.doc(selectedClub.id).update({
            'messages': messages,
          }).then((value) async {
            print('## messages sent');

            update();
          }).catchError((error) async {
            print('## messages failed to sent');
          });
        }
      });
    } else {
      print('## message cant be empty');
      showSnack('message cant be empty');
    }
  }

  streamingDoc(){
    print('##_start_chat_Streaming');

    if(selectedClub.id!=''){
      streamSub  = clubsColl.where('id', isEqualTo: selectedClub.id ).snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          print('##_CHANGE_chat_Streaming (new message) ');
          var chatDoc = snapshot.docs.first;
          messages.clear();
          messagesWidgets.clear();
          messages = chatDoc.get('messages');
          for(int i=0; i < messages.length ; i++ ){
            Map<String,dynamic> msg = messages[i.toString()];
            String msgText = msg['msg'];
            bool showTail =true;
            if(i < messages.length-1){
              Map<String,dynamic> nextMsg = messages[(i+1).toString()];
              if(msg['sender'] == nextMsg['sender']){
                showTail = false;
              }
            }
            bool isSender = cUser.name == msg['sender'];
            messagesWidgets.add(
              BubbleSpecialThree(
                text: msgText,
                textStyle: const TextStyle(
                    color: Colors.white
                ),
                tail: showTail,
                color: msgText.contains('has been added')?orangeCol: blueCol,
                //tail: true,
                isSender: isSender,
              ),
            );
          }
          if(layCtr.seenMessages<layCtr.messages.length){
            layCtr.badgeCount=layCtr.messages.length - layCtr.seenMessages;
          }
          Future.delayed(Duration(milliseconds: 20),(){update();});
        });
      });
    }else{
      print('##_no_ID_to_stream_yet');
    }



  }
  deleteMessages()async{
    bool accept = await showNoHeader(txt: 'are you sure you want to remove all these messages ? ',btnOkText: 'Remove');
    if(!accept) {
      return;
    }
    updateDoc(docID: selectedClub.id,coll: clubsColl,fieldsMap: {'messages':{}});
    showTos('all ${selectedClub.name} messages have been deleted',color: Colors.black87);
    //Get.back();
  }

  stopStreamingDoc(){
    streamSub.cancel();
    print('##_stop_chat_Streaming');
  }
}


class AddEvDia extends StatefulWidget {
  const AddEvDia({super.key});

  @override
  State<AddEvDia> createState() => _AddEvDiaState();
}
class _AddEvDiaState extends State<AddEvDia> {
  @override
  Widget build(BuildContext context) {

    return GetBuilder<LayoutCtr>(

        builder: (ctr) => SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: Form(
            key: layCtr.addEventKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 20,),

                /// title

                customTextField(
                  textInputType: TextInputType.text,
                  controller: layCtr.newEventTitleTec,
                  labelText: 'Title'.tr,
                  hintText: ''.tr,
                  icon: Icons.title,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "title can't be empty".tr;
                    }


                    return null;

                  },
                ),
                SizedBox(height: 18,),
                customTextField(
                  textInputType: TextInputType.text,
                  controller: layCtr.newEventDescTec,
                  labelText: 'Description'.tr,
                  hintText: ''.tr,
                  icon: Icons.description,
                  validator: (value) {

                    return null;

                  },
                ),
                SizedBox(height: 18,),

                /// image
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //add image
                    ButtonTheme(
                      buttonColor: dialogBtnOkTextCol,
                      //minWidth: 100.w  / 9,
                      child: ElevatedButton(
                        style: filledBtnStyle(color: dialogBtnOkCol.withOpacity(0.7)),
                        onPressed: () async {
                          PickedFile img = await showImageChoiceDialog();
                          layCtr.updateImage(img);
                        },
                        child: Text('Add Image'.tr),
                      ),
                    ),

                    //image_display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: SizedBox(
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: SizedBox(
                                  width: 23.w ,
                                  height: 15.w,
                                  //size: Size.fromRadius(30),
                                  child: layCtr.newItemImage != null
                                      ? Image.file(
                                    File(layCtr.newItemImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                      : Container(),
                                ),
                              ),
                            ),

                            ///delete
                            if (layCtr.newItemImage != null)
                              Positioned(
                                top: -11,
                                right: -11,
                                child: IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.grey,
                                    splashRadius: 1,
                                    onPressed: () {
                                      layCtr.deleteImage();
                                    }),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),




                /// buttons
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //cancel
                      TextButton(
                        style: borderBtnStyle(),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(color: dialogBtnCancelTextCol),
                        ),
                      ),
                      //add
                      TextButton(
                        style: filledBtnStyle(),
                        onPressed: () async {
                          if(layCtr.addEventKey.currentState!.validate()){
                            layCtr.addEventToDB();
                          }
                        },
                        child: Text(
                          "Add".tr,
                          style: TextStyle(color: dialogBtnOkTextCol ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

}
