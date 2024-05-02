import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:ionicons/ionicons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:line_icons/line_icons.dart';


import '../bindings.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';
import 'resetPwd.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailTec = TextEditingController();
  final TextEditingController passwordTec = TextEditingController();
  bool _isPwdObscure = true;
  Map creMap = Get.arguments!; //passed email,pwd


  login() async {
    if (_loginFormKey.currentState!.validate()) {
      authCtr.signIn(
          emailTec.text,
          passwordTec.text,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        emailTec.text= creMap['email']??'';
        passwordTec.text= creMap['pwd']??'';
      });
      //streamingDoc(usersColl,authCtr.cUser.id!);
    });

  }



  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF75b0b5),
      child: Scaffold(
        body:  SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),

                // logo Image
                Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                animatedText('Welcome to $appDisplayName',26,150),
                SizedBox(
                  height: 7.h,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [

                        //email field
                        customTextField(
                          controller: emailTec,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          icon: Icons.email,
                          isPwd: false,
                          obscure: false,
                          onSuffClick: (){},
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "email can't be empty";
                            }
                            if (!EmailValidator.validate(value)) {
                              return ("Enter a valid email");
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 25),

                        //pwd field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            customTextField(
                              controller: passwordTec,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              icon: Icons.lock,
                              isPwd: true,
                              obscure: _isPwdObscure,
                              onSuffClick: (){
                                setState(() {
                                  _isPwdObscure = !_isPwdObscure;
                                });
                              },
                              validator: (value) {
                                RegExp regex = RegExp(r'^.{6,}$');
                                if (value!.isEmpty) {
                                  return "password can't be empty"  .tr;
                                }
                                if (!regex.hasMatch(value)) {
                                  return ('Enter a valid password of at least 6 characters');
                                } else {
                                  return null;
                                }
                              },
                            ),
                            GestureDetector(
                              onTap: (){
                                Get.to(()=>ForgotPassword());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
                                child: Text('forgot password ?',style: TextStyle(
                                  color: normalTextCol,
                                  fontWeight: FontWeight.w400,
                                ),),
                              ),
                            ),
                          ],
                        ),


                        SizedBox(
                          height: 30,
                        ),

                        /// 'email' signIn
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [




                            SizedBox(width: 10,),

                            ///signIn
                            customButton(
                              reversed: true,
                              btnOnPress: () async {
                                login();
                              },
                              textBtn: 'Login',
                              btnWidth: 130,
                              icon: Icon(
                                LineIcons.arrowCircleRight,
                                color: btnIconCol,
                                size: 19,
                              ),
                            ),


                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        /// register sugg
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('you have no account ?',style: TextStyle(
                              color: normalTextCol,
                              fontWeight: FontWeight.w500,
                            ),),
                            TextButton(
                              onPressed: (() {
                                goRegister();

                              }),
                              child: Text(
                                'Sign Up',
                                style: const TextStyle(
                                  color: orangeCol,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),


                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        )
      ),
    );
  }
}
