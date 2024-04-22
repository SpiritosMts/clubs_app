


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'myVoids.dart';
import 'firebaseVoids.dart';



bool access = false;
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
Future<void> getPrivateData()async{
  if(await checkIfDocExists('prData','privateData') == false){
    var value = await addDocument(
      specificID: 'privateData',
      fieldsMap: {
        'access':true,
      },
      addIDField: false,
      coll: prDataColl,

    );
  }
  print('## getting PD(private Data) ...');
  List<DocumentSnapshot> privateData = await getDocumentsByColl(prDataColl);
  DocumentSnapshot privateDataDoc = privateData[0];// get first doc called 'private data'

  //all fields +
  access = privateDataDoc.get('access');



}