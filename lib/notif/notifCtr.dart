

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import '../bindings.dart';
import '../firebaseVoids.dart';
import '../firebase_options.dart';
import '../myVoids.dart';


//in bindings.dart (initialize ctr)
//in main.dart (initilize Fcm)
//after verify user and get its data (get token)

class FirebaseMessagingCtr extends GetxController {



  int messageCount = 0;
  String serverKey = 'AAAA2_kDUm0:APA91bFZZwv7SQ7QpIEx_6m2TTjwz2YouTY_82mZegQFGGU54FSsg1TkKrGydI1Yign5cEir3E93xczPdwqNubUjqpI4CuN3833JyA9byVrx5VGJfEzaXQmZjN3FMOTc5OHTnTokLk58';
  static const vapidKey = "ja4sOAzxnRTNMnOpiPO-Yk_WjFhLgdjDGvk7VaT6lsI";
  // used to pass messages from event handler to the UI
  String lastMessage = "";
  String token = "";
  String? initialMessage;
  bool resolved = false;
  bool isNotifActive = true;


  late Stream<String> _tokenStream;

  streamUserToken(){
    FirebaseMessaging.instance.getToken(vapidKey:vapidKey).then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  @override
  onInit() {
    super.onInit();
    print('## init FirebaseMessagingCtr');

    reqFcmPermission();

    // open when terminated ()
    FirebaseMessaging.instance.getInitialMessage().then((value) {
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
    updateFieldInFirestore(usersCollName,cUser.id,'deviceToken',_token,addSuccess: (){
      //print('## user_deviceToken in fb updated  <');
    });
  }




  /// CAll this to send notification (provide user device token which is stored in user info )
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
        print('##Response body: ${response.body}');
      } else {
        // Request failed
        print('## Request failed with status code: ${response.statusCode}');
        print('##Response body: ${response.body}');
      }


    } catch (e) {
      print('## error try send fcm: $e');
    }
  }




}

/// NOtification initilize
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
      'Products-ID', // id
      'Products Channel', // title
      description: 'This channel is used for products advertisement', // description
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notif_sound'),//android/app/src/main/res/raw

      playSound: true,
      enableVibration: true

  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
  print('## isFlutterLocalNotificationsInitialized = $isFlutterLocalNotificationsInitialized ');
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
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);

  print('## Handling a background message ${message.messageId}');
}
Future<void> showFlutterNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  Map<String, dynamic> data = message.data;
  AndroidNotification? android = message.notification?.android;
  String notificationImageUrl = message.notification?.android!.imageUrl??'';
  // final largeIconPath = await downloadImage(notificationImageUrl, notificationImageUrl);
  BigPictureStyleInformation? bigPictureStyleInformation ;
  if(notificationImageUrl != ''){
    final http.Response response = await http.get(Uri.parse(notificationImageUrl));
    bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)));

  }

  print('## notificationImage: "$notificationImageUrl"');



  if (notification != null && android != null && !kIsWeb) {

    if(ntfCtr.isNotifActive) flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        //iOS: ,
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          sound: RawResourceAndroidNotificationSound('notif_sound'),//android/app/src/main/res/raw
          icon: 'ic_notif_belaaraby',
          color: Colors.yellow,
          playSound: true,
          enableVibration: true,

          styleInformation: bigPictureStyleInformation,
          // largeIcon: DrawableResourceAndroidBitmap(largeIconPath.path), // Set the local image path as the large icon

//          largeIcon: await getLargeIconFromUrl(notificationImage), // Set the large icon here



        ),
      ),

    );

  }

}
