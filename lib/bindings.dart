

import 'package:get/get.dart';
import 'auth/authCtr.dart';
import 'generalLayout/generalLayoutCtr.dart';


AuthController authCtr = AuthController.instance;
LayoutCtr get layCtr => Get.find<LayoutCtr>();





class GetxBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController());
    Get.lazyPut<LayoutCtr>(() => LayoutCtr(),fenix: true);


  }
}