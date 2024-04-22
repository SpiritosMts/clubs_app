import 'dart:io';

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
  String appBarText =cUser.isAdmin? 'All Clubs':'My Clubs';//home
  List<Widget> appBarBtns=[];

  @override
  onInit() {
    super.onInit();
    print('## ## init LayoutCtr');
    sharedPrefs!.reload();
    Future.delayed(const Duration(milliseconds: 50), ()  async {
      refreshUsers();
      refreshRequests();
    });
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
        updateAppbar(title:cUser.isAdmin? 'All Clubs':'My Clubs',btns: []);
        if(!cUser.isAdmin){
          selectedClubs = myClubs;
        }else{
          selectedClubs = allClubs;

        }
        break;

      case 1:
        updateAppbar(title:cUser.isAdmin? 'Other Clubs':'Join Requests',btns: []);
        break;

      case 2:
        updateAppbar(title:cUser.isAdmin? 'All Users':'My Info',btns: cUser.isAdmin? [
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
        ]:[]);
        break;



      default:
        //updateAppbar(title:cUser.isAdmin? 'All Clubs':'My Clubs'.tr,btns: []);


    }
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
  selectClub(club){
    selectedClub=club;
    selectedEvents = selectedClub.events;
    selectedUsers = usersOfClub(layCtr.selectedClub);
    update();
  }

  List<ScUser> allUsers =[];
  List<Club> allClubs =[];
  List<JoinRequest> allRequests =[];

  List<Club> myClubs =[];
  List<Club> otherClubs =[];

  refreshUsers() async {
    allUsers = await getAlldocsModelsFromFb<ScUser>(
        true, usersColl, (json) => ScUser.fromJson(json),
        localKey: '');
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
          key: addEventKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 20,),

              /// title

              customTextField(
                textInputType: TextInputType.number,
                controller: newEventTitleTec,
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
                textInputType: TextInputType.number,
                controller: newEventDescTec,
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
                    //minWidth: 100.w  / 9,
                    child: ElevatedButton(
                      onPressed: () async {
                        PickedFile img = await showImageChoiceDialog();
                        updateImage(img);
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
                                child: newItemImage != null
                                    ? Image.file(
                                  File(newItemImage!.path),
                                  fit: BoxFit.cover,
                                )
                                    : Container(),
                              ),
                            ),
                          ),

                          ///delete
                          if (newItemImage != null)
                            Positioned(
                              top: -11,
                              right: -11,
                              child: IconButton(
                                  icon: const Icon(Icons.close),
                                  color: Colors.grey,
                                  splashRadius: 1,
                                  onPressed: () {
                                    deleteImage();
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
  addEventToDB() async {
    try{

    String specificID = Uuid().v1();

    /// add the image
    String itemImageUrl = await uploadOneImgToFb('clubs/${selectedClub.name}-${selectedClub.id}/events', newItemImage);

    ClubEvent newEvent = ClubEvent(
      title: newEventTitleTec.text,
      desc: newEventDescTec.text,
      date: todayToString(showHoursNminutes: true),
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
      newEventDescTec.clear();
      newEventTitleTec.clear();
    }catch  (err){
      print('## cant create event  : $err');
    }
  }

  ///clubs
  refreshClubs() async {
    allClubs = await getAlldocsModelsFromFb<Club>(
        true, clubsColl, (json) => Club.fromJson(json),
        localKey: '');
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
  }
  addClubDialog() {
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
                textInputType: TextInputType.number,
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
                textInputType: TextInputType.number,
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
                        if(addEventKey.currentState!.validate()){
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
    }catch  (err){
      print('## cant create club  : $err');
    }
  }
  openClub(){
    Get.to(()=>ClubDetails());
  }

/// req
  refreshRequests() async {
    allRequests = await getAlldocsModelsFromFb<JoinRequest>(
        true, requestsColl, (json) => JoinRequest.fromJson(json),
        localKey: '');
  }
  addRequest()async{

    bool accept = await showNoHeader(txt: 'are you sure you want to request to join "${selectedClub.name}" ?');
    if(!accept) return;
    JoinRequest newReq = JoinRequest(
      clubToJoinID: selectedClub.id,
      clubToJoinName: selectedClub.name,
      studentID: cUser.id,
      studentName: cUser.name,
    );
    try{
      String specificID = Uuid().v1();
      var value = await addDocument(
        specificID: specificID,
        fieldsMap: newReq.toJson(),
        coll: requestsColl,

      );
      Get.back(); //hide loading

    }catch  (err){
      print('## cant create request  : $err');
    }

  }
  acceptReq(JoinRequest req){
    // add user id to club members List of members IDs
    deleteDoc(docID: req.id,coll: requestsColl,success: (){//delete the request
      addElementsToList([req.studentID],'members',req.clubToJoinID,clubsCollName,canAddExistingElements: false);
    });
  }
  removeFromClub(ScUser usr) async {
    bool accept = await showNoHeader(txt: 'are you sure you want to remove ${usr.name} from ${selectedClub.name} club ?');
    if(!accept) return;
    // add user id to club members List of members IDs
      removeElementsFromList([usr.id],'members',selectedClub.id,clubsCollName);

  }

  declineReq(JoinRequest req){
    deleteDoc(docID: req.id,coll: requestsColl,success: (){

    });
  }


}