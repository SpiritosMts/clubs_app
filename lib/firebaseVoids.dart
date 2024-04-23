import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'bindings.dart';
import 'myVoids.dart';
import 'dart:io';

/// upload one file to fb
Future<String> uploadOneImgToFb(String filePath, PickedFile? imageFile) async {
  if (imageFile != null) {
    String fileName = path.basename(imageFile.path);
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('/$filePath/$fileName');

    File img = File(imageFile.path);

    final metadata = firebase_storage.SettableMetadata(contentType: 'image/jpeg', customMetadata: {
      // 'picked-file-path': 'picked000',
      // 'uploaded_by': 'A bad guy',
      // 'description': 'Some description...',
    });
    firebase_storage.UploadTask uploadTask = ref.putFile(img, metadata);

    String url = await (await uploadTask).ref.getDownloadURL();
    print('  ## uploaded image');

    return url;
  } else {
    print('  ## cant upload null image');
    return '';
  }
}

/// add DOCUMENT to fireStore
//  if specificID!='' ID will be added to 'prefs'
Future<void> addDocument(
    {required fieldsMap,
      required CollectionReference coll ,
      bool addIDField = true,
      String specificID = '',
      bool addRealTime = false,
      String docPathRealtime = '',
      Map<String, dynamic>? realtimeMap}) async {



  if (specificID != '') {
    coll.doc(specificID).set(fieldsMap).then((value) async {
      print("## DOC ADDED TO <${coll.path}>");

      //add id to doc
      if (addIDField) {
        //set id
        coll.doc(specificID).update(
          {
            ///this
            'id': specificID,
          },
          //SetOptions(merge: true),
        );
        if (addRealTime) {
          DatabaseReference serverData = database!.ref(docPathRealtime);
          await serverData.update({"$specificID": realtimeMap}).then((value) async {});
        }
      }
    }).catchError((error) {
      print("## Failed to add doc to <${coll.path}>: $error");
    });
  } else {
    coll.add(fieldsMap).then((value) async {
      print("## DOC ADDED TO <${coll.path}>");

      //add id to doc
      if (addIDField) {
        String docID = value.id;
        //set id
        coll.doc(docID).update(
          {
            ///this
            'id': docID,
          },
          //SetOptions(merge: true),
        );
        if (addRealTime) {
          DatabaseReference serverData = database!.ref(docPathRealtime);
          await serverData.update({"$docID": realtimeMap}).then((value) async {});
        }
      }
    }).catchError((error) {
      print("## Failed to add doc to <${coll.path}>: $error");
      showSnack(snapshotErrorMsg,color:Colors.black54);
      throw Exception('## Exception ');


    });
  }
}

/// UPDATE document
Future<void> updateDoc({required CollectionReference coll , required String docID, Map<String, dynamic> fieldsMap = const {}}) async {

  await coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      await coll.doc(docID).update(fieldsMap).then((value) async {
        showSnack('doc updated'.tr);
        print('## doc updated');
        //Get.back();//cz it in dialog
      }).catchError((error) async {
        showSnack('doc failed to updated'.tr);
        print('## doc falide to updated');
        throw Exception('## Exception ');

      });
    }
  });
}

/// delete by url
Future<void> deleteFileByUrlFromStorage(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {
    print("Error deleting file: $e");
  }
}

Future<void> addElementsToList(List newElements, String fieldName, String docID, String collName, {bool canAddExistingElements = true}) async {
  print('## start adding list <$newElements> TO <$fieldName>_<$docID>_<$collName>');

  CollectionReference coll = FirebaseFirestore.instance.collection(collName);

  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      // export existing elements
      List<dynamic> oldElements = documentSnapshot.get(fieldName);
      print('## oldElements: $oldElements');
      // element to add
      List<dynamic> elementsToAdd = [];
      if (canAddExistingElements) {
        elementsToAdd = newElements;
      } else {
        for (var element in newElements) {
          if (!oldElements.contains(element)) {
            elementsToAdd.add(element);
          }
        }
      }

      print('## elementsToAdd: $elementsToAdd');
      // add element
      List<dynamic> newElementList = oldElements + elementsToAdd;
      print('## newElementListMerged: $newElementList');

      //save elements
      await coll.doc(docID).update(
        {
          fieldName: newElementList,
        },
      ).then((value) async {
        print('## successfully added list <$elementsToAdd> TO <$fieldName>_<$docID>_<$collName>');
      }).catchError((error) async {
        print('## failure to add list <$elementsToAdd> TO <$fieldName>_<$docID>_<$collName>');
      });
    } else if (!documentSnapshot.exists) {
      print('## docID not existing');
    }
  });
}

Future<void> removeElementsFromList(List elements, String fieldName, String docID, String collName) async {
  print('## start deleting list <$elements>_<$fieldName>_$docID>_<$collName>');

  CollectionReference coll = FirebaseFirestore.instance.collection(collName);

  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      // export existing elements
      List<dynamic> oldElements = documentSnapshot.get(fieldName);
      print('## oldElements:(before delete) $oldElements');

      // remove elements from oldElements
      List<dynamic> elementsRemoved = [];

      for (var element in elements) {
        if (oldElements.contains(element)) {
          oldElements.removeWhere((e) => e == element);
          elementsRemoved.add(element);
          //print('# removed <$element> from <$oldElements>');
        }
      }

      print('## oldElements:(after delete) $oldElements');
      await coll.doc(docID).update(
        {
          fieldName: oldElements,
        },
      ).then((value) async {
        print('## successfully deleted list <$elementsRemoved> FROM <$fieldName>_<$docID>_<$collName>');
      }).catchError((error) async {
        print('## failure to delete list <$elementsRemoved> FROM  <$fieldName>_<$docID>_<$collName>');
      });
    } else if (!documentSnapshot.exists) {
      print('## docID not existing');
    }
  });
}


clearCollection(CollectionReference coll) async {
  var snapshots = await coll.get();
  for (var doc in snapshots.docs) {
    print('# delete doc<${doc.id}>');
    await doc.reference.delete();
  }
}

Future<List<String>> getDocumentsIDsByFieldName(String fieldName, String filedValue, CollectionReference coll) async {
  QuerySnapshot snap = await coll
      .where(fieldName, isEqualTo: filedValue) //condition
      .get();

  List<String> docsIDs = [];
  final List<DocumentSnapshot> documentsFound = snap.docs;
  for (var doc in documentsFound) {
    docsIDs.add(doc.id);
  }
  print('## docs has [$fieldName=$filedValue] =>$docsIDs');

  return docsIDs;
}

Future<List<DocumentSnapshot>> getDocumentsByColl(CollectionReference coll) async {
  List<DocumentSnapshot> documentsFound =[];

  try{
    QuerySnapshot snap = await coll.get();
    documentsFound = snap.docs; //return QueryDocumentSnapshot .data() to convert to json// or "userDoc.get('email')" for each field
  }catch(err){
    print('## Failed to get docs in coll<${coll.path}>: $err');
    throw Exception('## Exception ');
  }
  return documentsFound;
}

/// ////////////////// Get & Set 1 Field in FB //////////////////////////////////////////////////////////////////////////////////////////////////
Future<void> updateFieldInFirestore( //use aawait with it
 CollectionReference coll,
    String docId,
    String fieldName,
    dynamic fieldValue, {
      Function()? addSuccess,
    })async {

  try {

    await coll.doc(docId).update({
      fieldName: fieldValue,
    });
    print('## Field updated successfully <${coll.path}/$docId/$fieldName> = <$fieldValue>');
    if (addSuccess != null) addSuccess();
  } catch (error) {
    print('## Error updating field <${coll.path}/$docId/$fieldName> = <$fieldValue>  ///ERROR : $error ///');
    throw Exception('## Exception ');

  }

}

Future<dynamic> getFieldFromFirestore( CollectionReference coll, String docId, String fieldName) async {
  try {
    DocumentSnapshot snapshot = await coll.doc(docId).get();
    if (snapshot.exists) {
      dynamic docMap = snapshot.data() as Map<String, dynamic>;
      dynamic fieldValue = docMap[fieldName];

      if (fieldValue is int) {
        return fieldValue.toDouble(); // Convert int to double
      } else {
        return fieldValue;
      }
    } else {
      print('## Document not found <${coll.path}/$docId>');
      return null;
    }
  } catch (error) {
    print('## Error retrieving field <${coll.path}/$docId/$fieldName> : $error');
    throw Exception('## Exception ');

  }
}

/// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<List<T>> getAlldocsModelsFromFb<T>(bool online, CollectionReference coll, T Function(Map<String, dynamic>) fromJson,
    {String? localKey}) async {
  //print('## getting  "$localKey" from ${online? '"DB"':'"PREFS"' } ...');

  List<T> models = [];

  if (online) {
    //online
    List<DocumentSnapshot> docs = await getDocumentsByColl(coll);
    for (var doc in docs) {
      T model = fromJson(doc.data() as Map<String, dynamic>);
      models.add(model);
    }
    print('## from "DB" ## downloaded (${models.length}) models; collection <${coll.path}>');


  } else {//offline

  }

  return models;
}

Future<List<DocumentSnapshot>> getDocumentsByIDs(
  CollectionReference coll, {
  List<String> IDs = const [],
}) async {
  // List userStoresIDs = authCtr.cUser.stores!;
  List userStoresIDs = [];
  QuerySnapshot snap = (IDs != [] ? await coll.where('id', whereIn: IDs).get() : await coll.get());

  final documentsMap = snap.docs;

  print('## collection:<${coll.path}> docs length =(${documentsMap.length})');

  return documentsMap;
}

Future<bool> checkDocExist(String docID, coll) async {
  var docSnapshot = await coll.doc(docID).get();

  if (docSnapshot.exists) {
    print('## docs with id=<$docID> exists');
  } else {
    print('## docs with <id=$docID> NOT exists');
  }
  return docSnapshot.exists;
}

/// Check If Document Exists
Future<bool> checkIfDocExists(String collName, String docId) async {
  try {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(collName);
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  } catch (e) {
    throw e;
  }
}





Future<void> deleteDoc({Function()? success, required String docID,required CollectionReference coll})async {
  //if docID doesnt exist it will success to remove
  await coll.doc(docID).delete().then((value) async {
    print('## document<$docID> from <${coll.path}> deleted');
    if(success!=null) success();
    //showSnack('doc deleted'.tr, color: Colors.redAccent.withOpacity(0.8));
  }).catchError((error) async {
    print('## document<$docID> from <${coll.path}> deleting error = ${error}');
    showSnack(snapshotErrorMsg,color:Colors.black54);
    throw Exception('## Exception ');

  });

}

deleteUserFromAuth(email, pwd) async {
  //auth user to delete
  await firebaseAuth
      .signInWithEmailAndPassword(
    email: email,
    password: pwd,
  )
      .then((value) async {
    print('## account: <${authCurrUser!.email}> deleted');
    //delete user
    authCurrUser!.delete();
    //signIn with admin
    await firebaseAuth.signInWithEmailAndPassword(
      email: authCtr.cUser.email!,
      password: authCtr.cUser.pwd!,
    );
    print('## admin: <${authCurrUser!.email}> reSigned in');
  });
}



void deleteFromMap({coll, docID, fieldMapName, String mapKeyToDelete ='', bool withBackDialog = false, String targetInvID ='', Function()? addSuccess,}) {

  //we need either targetInvID or mapKeyToDelete to delete item from map
  print('## try deleting map in ${coll}/$docID/$fieldMapName/$mapKeyToDelete');
  if(targetInvID!='') print('## targetInvID = <$targetInvID> ');// delete map B in map A by ""value"" in map B,
  if(mapKeyToDelete!='') print('## mapKeyToDelete = <$mapKeyToDelete>');// delete map B in map A by ""key"" of map B,

  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      try {
        Map<String, dynamic> fieldMap = documentSnapshot.get(fieldMapName);
        String keyToDelete = mapKeyToDelete;
        //search map key depending on specific value
        if (targetInvID != '') {
          for (var entry in fieldMap.entries) {
            if (entry.value['id'] == targetInvID) { //the ID name in the map
              keyToDelete = entry.key;
            }
          }
        }

        if (fieldMap.containsKey(keyToDelete)) {
          fieldMap.remove(keyToDelete);
          if (addSuccess != null) addSuccess();
        } else {
          print('## hisTr not found or already deleted');
          return;
        }


        await coll.doc(docID).update({
          '${fieldMapName}': fieldMap,
        });

        //------- success

        print('## item from fieldMap<$fieldMapName> deleted');


      }catch(error){
        print('## ERROR: item from fieldMap <$fieldMapName> FAILED to deleted: $error');
        throw Exception('## Exception ');

      }
    } else {
      print('## doc<$docID> dont exist');
    }
  }).catchError((error) async {
    print('## ERROR: FAILED to even get  ${coll}/$docID/ : $error');
  });
}
Map<String, dynamic>  deleteFromMapLocal({mapInitial, String mapKeyToDelete ='', String targetInvID ='', Function()? addSuccess,}) {

  Map<String, dynamic> fieldMap = {};
  //we need either targetInvID or mapKeyToDelete to delete item from map
  if(targetInvID!='') print('## targetInvID = <$targetInvID> ');// delete map B in map A by ""value"" in map B,
  if(mapKeyToDelete!='') print('## mapKeyToDelete = <$mapKeyToDelete>');// delete map B in map A by ""key"" of map B,

  try {

    fieldMap = mapInitial;
    String keyToDelete = mapKeyToDelete;
    //search map key depending on specific value
    if (targetInvID != '') {
      for (var entry in fieldMap.entries) {
        if (entry.value['invID'] == targetInvID) {
          keyToDelete = entry.key;
        }
      }
    }

    print('## key To Delete = ${keyToDelete} ');


    if (fieldMap.containsKey(keyToDelete)) {
      fieldMap.remove(keyToDelete);
      if(addSuccess!= null) addSuccess();
    } else {
      print('## hisTr not found or already deleted');
    }


  }catch(error)  {
    print('## ERROR: FAILED to remove key="$mapKeyToDelete" : $error');
    throw Exception('## Exception ');

  };
  return fieldMap;
}



Future<void> addToMap({coll, docID, fieldMapName, mapToAdd, Function()? addSuccess, bool withBackDialog = false}) async{
  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      Map<String, dynamic> fieldMap = documentSnapshot.get(fieldMapName);

      //int newItemIndex = fieldMap.length ;

      //New  item to ADD
      fieldMap[getLastIndex(fieldMap, afterLast: true)] = mapToAdd;

      await coll.doc(docID).update({
        '${fieldMapName}': fieldMap,
      }).then((value) async {
        if (withBackDialog) Get.back();
        print('## item to fieldMap added');
        //showSnack('item added', color: Colors.black54);
        if(addSuccess != null) addSuccess();
      }).catchError((error) async {
        print('## item to fieldMap FAILED to added');
        showSnack(snapshotErrorMsg,color:Colors.black54);

        //showSnack('item failed to be added', color: Colors.redAccent.withOpacity(0.8));
      });
    } else {
      print('## doc<$docID> dont exist');
    }
  });
}

Future<void> addToMap0({coll, docID, fieldMapName, mapToAdd, Function()? addSuccess, bool withBackDialog = false}) async {
  coll.doc(docID).get().then((DocumentSnapshot documentSnapshot) async {
    if (documentSnapshot.exists) {
      dynamic fieldData = documentSnapshot.get(fieldMapName);

      if (fieldData is Map<String, dynamic>) {
        // Safe to proceed because the data is a map
        Map<String, dynamic> fieldMap = fieldData;

        // Add new item to the map
        fieldMap[getLastIndex(fieldMap, afterLast: true)] = mapToAdd;

        await coll.doc(docID).update({
          '${fieldMapName}': fieldMap,
        }).then((value) async {
          if (withBackDialog) {
            Get.back();
          }
          print('## item to fieldMap added');
          if (addSuccess != null) {
            addSuccess();
          }
        }).catchError((error) async {
          print('## item to fieldMap FAILED to added');
          showSnack(snapshotErrorMsg, color: Colors.black54);
        });
      } else {
        // Handle the case where the data is not a map
        print('Error: Expected a Map<String, dynamic> but found a different type');
        // Optionally, you could raise an exception or take other actions here
      }
    } else {
      print('## doc<$docID> does not exist');
    }
  });
}


/// //////////////////////////////////////// MANUAL CHNAGES TEST ////////////////////////////////////////////


changeAllDocsManual() async {
  String collectionName = 'invoices'; /// <<<<<<< changeable for test

  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  QuerySnapshot querySnapshot = await collection.get();

  int i =1;

  /// Loop through each document
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool conditionToAdd = !data.containsKey('deliveryMatFis') || !data.containsKey('index');
    if(true){
      print('## change ( $i )<${doc.id}>');
      await collection.doc(doc.id).update({
        'isBuy': false,
        //'index': i.toString(),
      });
    }


    i++;//last
  }
}

Future<void> removeFieldFromAllDocs() async {
  String collectionName = 'invoices'; /// <<<<<<< changeable for test

  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  QuerySnapshot querySnapshot = await collection.get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {


    await collection.doc(doc.id).update({
      //'matriculeFis': FieldValue.delete(),
    });
  }
}

