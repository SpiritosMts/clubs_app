

import 'package:get/get.dart';
import 'auth/authCtr.dart';
import 'fcm/fcmCtr.dart';
import 'generalLayout/generalLayoutCtr.dart';


AuthController authCtr = AuthController.instance;
LayoutCtr get layCtr => Get.find<LayoutCtr>();
FirebaseMessagingCtr get fcmCtr => Get.find<FirebaseMessagingCtr>();





class GetxBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FirebaseMessagingCtr>(FirebaseMessagingCtr());
    Get.put<AuthController>(AuthController());
    Get.lazyPut<LayoutCtr>(() => LayoutCtr(),fenix: true);


  }
}