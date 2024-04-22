

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'myVoids.dart';

//intro
const Color introBackColor = bgCol;

//snackBar
const Color snackBarError = Colors.redAccent;
const Color snackBarNormal = Colors.black45;
const Color snackBarSuccessful = Colors.greenAccent;

//auth
const Color animatedTextCol = logoBlue;
const Color loginUsingCol = logoBlue;
const Color typeBtnColor = logoBlue80;
const Color registerTitleColor = logoBlue;
const Color registerSubtitleColor = logoBlue;
const Color registerBtnCol = blueCol;
const Color registerBtnBorderCol = blueCol;


//text
const Color normalTextCol = logoBlue;
const Color transparentTextCol = logoBlue80;



//appbar
const Color appBarUnderlineColor  = blueCol;
const Color appBarNotificationBellColor  = blueCol;
const Color appBarTitleColor  = blueCol;//add style
const Color appBarBgColor  = Colors.white;
const Color appBarButtonsCol  = blueCol;// add sttyle
//navbar
const Color navBarActive = blueCol;
const Color navBarDesactive = Colors.grey;
const Color navBarBgColor = Colors.white;

//buttons
const Color disabledBtnFillCol = Colors.grey;//enable
const Color btnFillCol   = blueCol80;
const Color disabledBtnBorderCol = Colors.grey;//disable
const Color btnBorderCol   = blueCol80;
const Color btnTextCol = Colors.white;
const Color btnIconCol = btnTextCol;


//loading
const Color loadingCol   = blueCol;
const Color loadingDialogCol   = blueCol;
const Color splashLoadingCol   = logoBlue;

//products
const Color elementNotFoundColor   = Colors.grey;//Add style
const Color plusMinusIconCol = blueCol;
const Color plusMinusErrorIconCol = Color(0x80666666);//grey;
const Color plusMinusBgCol = blueCol30;
const Color plusMinusErrorBgCol = Color(0x20666666);//grey;
const Color productCardColor  = Colors.white;
const Color productBorderCol = productCardColor;
const Color productEditSwipeCol = blueCol;
const Color productRemoveSwipeCol = orangeCol;

const Color qtyCol = logoBlue;//style
const Color errorQtyCol = Colors.redAccent;
const Color buyCol = logoBlue;//style
const Color errorBuyCol = Colors.redAccent;
const Color sellCol = logoBlue;//style
const Color errorSellyCol = Colors.redAccent;
const Color squareDateCol = transparentTextCol;



//dialog
const chartValuesCol = Colors.white;
const Color dialogBgCol = bgCol  ;
const Color dialogTitleCol   = blueCol;//add style
const Color dialogAweInfoCol   = Colors.blueAccent;//add style
const Color dialogDescCol   = normalTextCol;//add style
const Color dialogBtnOkTextCol  =Colors.white;
const Color dialogBtnCancelTextCol  =Colors.black87;
const Color dialogBtnOkCol   = blueCol;
const Color dialogBtnCancelCol   = orangeCol;

//textField
const Color dialogFieldLabelCol = Color(0xFF666666);//grey
const Color dialogFieldHintCol   = Colors.grey;
const Color dialogFieldWriteCol   = Colors.black87;
const Color dialogFieldIconCol   = orangeCol;
const Color dialogFieldEnableBorderCol   = Color(0x60999999);//grey with opacity 60
const Color dialogFieldDisableBorderCol   = Colors.grey;
const Color dialogFieldErrorFocusBorderCol   = Colors.redAccent;
const Color dialogFieldErrorUnfocusBorderCol   = Colors.redAccent;
const Color dialogFieldBorderCol   = Colors.grey;

//icons
const Color iconCol = blueCol;

//invoice
const Color winIncomeCol   = Colors.greenAccent;
const Color errorColor   = Colors.redAccent;
const Color looseIncomeCol  = Colors.red;
const Color totalCol  = Colors.lightBlueAccent;
const Color waitingCol  = Color(0xFFFFD700);
const Color invBuyCol  = Color(0xFFffed89);

//settings
const Color settingTitlesColor  = blueCol;
const Color leadingIconsColor  = Colors.black87;
const Color tileDescriptionTextColor  = Colors.grey;

//card
const Color cardColor  = Colors.white;
const Color activeCardBorder = Colors.lightBlueAccent;
const Color normalCardBorder   = Colors.white38;

//hint text
const hintPrimColor = Color(0X60569AEA);


//divider
const Color dividerColor  = Colors.white;

//bg
const bgCol = greyCol;

//dropdown
const dropDownCol = greyCol;
const fillCol = transparentTextCol;

/// ***********  palette ****************************
const greyCol = Color(0XffE2E6F2);
const orangeCol = Color(0Xffda6c48);
const lightGreyCol = Color(0xff404B60);
const redCol = Color(0XffE32B2B);
const yellowCol = Color(0XffF3C30B);
const greenCol = Color(0Xff64C3AF);
const blueCol = Color(0xFF48b6da);
const blueCol80 = Color(0x8048b6da);
const blueCol40 = Color(0x4048b6da);
const blueCol30 = Color(0x3048b6da);

const logoBlue = Color(0xFF15355A);
const logoBlue80 = Color(0x8015355A);
const logoOrange = Color(0xFFF48120);
/// ******************** ****************************

const Color primaryColor = Color(0xFF0097A7);
const Color accentColor0   = Color(0xFF024855);


final MaterialColor primarySwatch = MaterialColor(0xFF48b6da, {
  50: Color(0xFFE0F4FA),
  100: Color(0xFFB3E5FC),
  200: Color(0xFF81D4FA),
  300: Color(0xFF4FC3F7),
  400: Color(0xFF29B6F6),
  500: Color(0xFF03A9F4), // This is the primary color
  600: Color(0xFF039BE5),
  700: Color(0xFF0288D1),
  800: Color(0xFF0277BD),
  900: Color(0xFF01579B),
});


ButtonStyle blueStyle = TextButton.styleFrom(
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  backgroundColor: blueCol,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
);
/// //////////////// LIGHT /////////////////////////////////////////////////////////////////////////
/// //////////////// LIGHT /////////////////////////////////////////////////////////////////////////
/// //////////////// LIGHT /////////////////////////////////////////////////////////////////////////
ThemeData customLightTheme = ThemeData(
  useMaterial3: false,

  brightness: Brightness.light,
  scaffoldBackgroundColor: bgCol,
  primarySwatch: primarySwatch,
  unselectedWidgetColor: Colors.white24,

  //canvasColor: bgCol,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  tabBarTheme: TabBarTheme(
    unselectedLabelColor: Colors.white38,
    labelColor: Colors.white,
    indicatorColor: Colors.white,

    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: Colors.white, // Color of the tab indicator
        width: 3.0, // Thickness of the indicator
      ),
      insets: EdgeInsets.only(bottom: 8), // Distance from the bottom of the TabBar
    ),
  ),

  listTileTheme: ListTileThemeData(
    iconColor: navBarActive,
  ),

  iconTheme: IconThemeData(
      color: navBarActive
  ),

  inputDecorationTheme:  InputDecorationTheme(
    contentPadding:  EdgeInsets.only(top: 0,bottom: 15),
fillColor: normalTextCol,

    disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: transparentTextCol,
          width: 1,
        )),
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: transparentTextCol,
          width: 1,
        )),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: blueCol, width: 2),
    ),
    focusColor: normalTextCol
  ),
  dividerColor: Colors.white,

  hintColor: hintPrimColor,

  textTheme: textThemeGlob.apply(
    decoration: TextDecoration.none,
    decorationColor: Colors.white,
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  colorScheme: ColorScheme.fromSwatch(

    accentColor: primarySwatch,
    backgroundColor: bgCol,
    primarySwatch: primarySwatch,
  ).copyWith(secondary: primarySwatch),
  //appbar

  primaryColor: primarySwatch,


  buttonTheme:  ButtonThemeData(
    buttonColor: primarySwatch,
    disabledColor: Colors.grey,
  ),
);
/// //////////////// DARK /////////////////////////////////////////////////////////////////////////
/// //////////////// DARK /////////////////////////////////////////////////////////////////////////
/// //////////////// DARK /////////////////////////////////////////////////////////////////////////
ThemeData customDarkTheme = ThemeData(

);
/// ##########################################################################
/// ##########################################################################



//buttons
ButtonStyle borderBtnStyle({Color color = dialogBtnCancelCol}){
  return TextButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    shape: RoundedRectangleBorder(
        side:  BorderSide(color: color, width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(100)),
  );
}

ButtonStyle filledBtnStyle({Color color = dialogBtnOkCol}){
  return TextButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
  );
}


Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

appBarUnderline(){
  return PreferredSize(
      preferredSize: Size.fromHeight(4.0),
      child: Container(
        color: appBarUnderlineColor,
        height: 2.0,
      ));
}
Widget appNameText() {
  return Text(
    '${appDisplayName}',
    textAlign: TextAlign.center,
    style: GoogleFonts.indieFlower(
      textStyle: TextStyle(fontSize: 33, color: orangeCol, fontWeight: FontWeight.w700, letterSpacing: 5),
    ),
  );
}

final TextTheme textThemeGlob = TextTheme(
  headline1: GoogleFonts.almarai(fontSize: 97, fontWeight: FontWeight.w300, letterSpacing: -1.5),
  headline2: GoogleFonts.almarai(fontSize: 61, fontWeight: FontWeight.w300, letterSpacing: -0.5),
  headline3: GoogleFonts.almarai(fontSize: 48, fontWeight: FontWeight.w400),
  headline4: GoogleFonts.almarai(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  headline5: GoogleFonts.almarai(fontSize: 24, fontWeight: FontWeight.w400),
  headline6: GoogleFonts.almarai(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  subtitle1: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
  subtitle2: GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  bodyText1: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyText2: GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  button: GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
  caption: GoogleFonts.almarai(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  overline: GoogleFonts.almarai(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
);

