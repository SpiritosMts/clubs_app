
import 'dart:convert';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import '../firebaseVoids.dart';
import '../myVoids.dart';
import 'fcmVoids.dart';

class FirebaseMessagingCtr extends GetxController {



  int messageCount = 0;
  String serverKey = 'AAAA2_kDUm0:APA91bFZZwv7SQ7QpIEx_6m2TTjwz2YouTY_82mZegQFGGU54FSsg1TkKrGydI1Yign5cEir3E93xczPdwqNubUjqpI4CuN3833JyA9byVrx5VGJfEzaXQmZjN3FMOTc5OHTnTokLk58';
  static const vapidKey = "ja4sOAzxnRTNMnOpiPO-Yk_WjFhLgdjDGvk7VaT6lsI";//in firebase > project settings > cloud messaging
  // used to pass messages from event handler to the UI
  final messageStreamController = BehaviorSubject<RemoteMessage>();
  String lastMessage = "";
  String token = "";
  String? initialMessage;
  bool resolved = false;


  late Stream<String> _tokenStream;

  streamUserToken(){
    FirebaseMessaging.instance.getToken(vapidKey:vapidKey).then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }
  Future<void> reqFcmPermission() async {

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('## Fcm Permission granted: ${settings.authorizationStatus}');
    }
  }

  @override
  onInit() {
    super.onInit();
    print('## init FirebaseMessagingCtr');

    reqFcmPermission();


    // open when terminated ()
    FirebaseMessaging.instance.getInitialMessage().then(
          (value) {
            resolved = true;
            initialMessage = value?.data.toString();

            update();
          });

    //foreground receive
    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    // open when not terminated (foregroung / background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('## A new onMessageOpenedApp event was published! ##');

    });
  }




  void setToken(String? _token) {
    print('## this device FCM Token: $_token');
      token = _token!;
    updateFieldInFirestore(usersColl,cUser.id,'deviceToken',_token,addSuccess: (){

    });

    }



  Future<void> sendPushMessage({String receiverToken='',String title='',String body='',String imageUrl='',Map<String,dynamic> data= const{} }) async {
    if (receiverToken == '') {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
    String constructFCMPayload(String? token) {
      messageCount++;
      return jsonEncode({
        //'token': token,
        'to': token,
        'data': data,
        'notification': {
          'title': title,
          'body': body,
          "image": imageUrl,
        },
      });
    }

    try {
      // Make the HTTP POST request
      final response =await http.post(
               Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey',
        },
        body: constructFCMPayload(receiverToken),
      );
      // Check the HTTP status code
      if (response.statusCode == 200) {
        // Request was successful
        print('## FCM request for device sent!');
        print('Response body: ${response.body}');
      } else {
        // Request failed
        print('## Request failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }


    } catch (e) {
      print('## error try send fcm: $e');
    }
  }




}
