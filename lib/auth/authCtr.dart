

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';


import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../bindings.dart';
import '../firebaseVoids.dart';
import '../models/user.dart';
import '../myVoids.dart';



class AuthController extends GetxController {
  static AuthController instance = Get.find();
  ScUser cUser = ScUser();
  late Rx<User?> firebaseUser;
  String enteredPwd ='';//make this to update user pwd in fs after login (to track the reset pwd he did)
  late  Worker worker;


  late  StreamSubscription<QuerySnapshot> streamSub;



  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 0), () {

    });
  }
  @override
  void onClose() {
    super.onClose();

  }

  /// ************************************************************************************************************







  void fetchUser() {
    print('## AuthController fetching User ...');

    firebaseUser = Rx<User?>(firebaseAuth.currentUser);

    firebaseUser.bindStream(firebaseAuth.userChanges());
    worker = ever(firebaseUser, _setInitialScreen);
  }
  _setInitialScreen(User? user) async {
    worker.dispose();

    if (user == null) {//no user found (not already signed in)
      print('## no user already registered => go login_page');
      await goLogin();


    } else {//user found (already signed in)

      if(user.email == null || user.email == '') {
        print('## user already logged in but email is <NULL>');
        authCtr.signOutUser(shouldGoLogin: true);//user already logged in but email is <NULL> or empty
        return;
      }

      print('## user<${user.email}> already signed in =>try go home_page if its verified');
      await getUserInfoByEmail(user.email,isLoadingScreen: true).then((value) {//while fetching...
      });

    }
  }






  ///  EMAIL 'signIn' + 'signUp'
  signIn(String _email, String _password) async {
    try {
      print('## Email signing In ...');

      //try signIn
      await firebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      ).then((value)  async {//account found
        await authCtr.getUserInfoByEmail(_email);

        print('## user credential available => ${value.user.toString()}');
      });

      // signIn error
    } on FirebaseAuthException catch (e) {
      //Get.back();

      print('## error signIn, msg:<${e.message}>, code:<${e.code}>, credential:<${e.credential}>');
      if (e.code == 'user-not-found') {
        showTos('User not found');
      } else if (e.code == 'wrong-password') {
        showTos('Wrong password');
      }
      else{
        showTos('There was an issue verifying the information you provided.');
      }
    } catch (e) {
      //Get.back();
      print('## catch err in signIn user_auth: $e');
    }
  }
  signUp(String _email, String _password, {Function()? onSignUp}) async {
    try {
      print('## Email signing In ...');

      await firebaseAuth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      )
          .then((value) {
        onSignUp!();
      });

    } on FirebaseAuthException catch (e) {
      print('## error signUp, msg:<${e.message}>, code:<${e.code}>, credential:<${e.credential}>');
      //Get.back();

      if (e.code == 'weak-password') {
        showTos('Weak password');
      } else if (e.code == 'email-already-in-use') {
        showTos('Email already in use');
      }
      else{
        showTos('Please verify your credentials and try again.');
      }
    } catch (e) {
      //Get.back();

      print('## catch err in signUp user_auth: $e');
    }
  }
  /// ///////




  List roles = [
    'Student',
    'Admin',
  ] ;


  /// Forgot Pwd
  void ResetPss(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email).then((uid) {
        showTos('A password reset link has been sent to your email address.');
        //Get.back();
      });

    } on FirebaseAuthException catch (e) {
      print('## error resetPwd, msg:<${e.message}>, code:<${e.code}>, credential:<${e.credential}>');

      showTos('connection error');

    }catch (e) {
      //Get.back();

      print('## catch err in resetPwd user_auth: $e');
    }
  }

  void signOutUser({bool shouldGoLogin = false,bool dbLogOut = false,}) async {
    try {
      print('## signing Out . . . ');

      final signOutTasks = [
        firebaseAuth.signOut(),

      ];

      await Future.wait(signOutTasks);


      if (shouldGoLogin) {
        await goLogin(email: authCtr.cUser.email);
      }
      // Reset the user state
      authCtr.cUser = ScUser();
      print('## signed Out ');



    } catch (e) {
      print('## Sign-out failed: $e');
    }
  }





  /// GET-USER-INFO VY PROP
  Future<void> getUserInfoByEmail(userEmail,{bool isLoadingScreen = false}) async {
    print('## getting user info by email < $userEmail > . ..');

    await usersColl.where('email', isEqualTo: userEmail).get().then((event) async {
      var userDoc = event.docs.single;
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>; // Explicit casting
        cUser = ScUser.fromJson(userData);
        ntfCtr.streamUserToken();//get & start token streaming
        printJson(cUser.toJson());

      } else {
        print('## user doc with email < $userEmail >  dont exist ');
      }
      goHome();


    }).catchError((e) {
      print("## cant find user in db (email_search): $e");
      if(isLoadingScreen) signOutUser(shouldGoLogin: true);// go login if you cant get your user model

    });


  }


}