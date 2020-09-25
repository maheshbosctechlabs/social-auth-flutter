import 'package:flutter/material.dart';
import 'package:Social_Media_Login/common/colors.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //This variable is used to check the current user is sign in as google.
  bool _isGoogleLoggedIn = false;

  //This is the object of GoogleSignIn class which is used for Google login & logout functionality.
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  //This variable is used for check current user is sign in as facebook.
  bool _isFBLoggedIn = false;

  //This variable is used for mapping with facebook user data response.
  Map userProfile;

  //This is object of FacebookLogin class which is used for Facebook login & logout functionality.
  final facebookLogin = FacebookLogin();

  //This method is used for Google login request
  _googleLogin() async {
    try {
      await _googleSignIn.signIn();
      setState(() {
        _googleSignIn.currentUser != null
            ? _isGoogleLoggedIn = true
            : _isGoogleLoggedIn = false;
      });
    } catch (err) {
      print(err);
    }
  }

  //This method is used for Google logout request
  _googleLogout() {
    _googleSignIn.signOut();
    setState(() {
      _isGoogleLoggedIn = false;
    });
  }

  //This method is used for Facebook login request
  _facebookLogin() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');
        //{token};
        final profile = JSON.jsonDecode(graphResponse.body);
        //print(profile);
        setState(() {
          userProfile = profile;
          _isFBLoggedIn = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isFBLoggedIn = false);
        break;

      case FacebookLoginStatus.error:
        setState(() => _isFBLoggedIn = false);
        break;
    }
  }

  //This method is used for Facebook logout
  _facebookLogout() {
    facebookLogin.logOut();
    setState(() {
      _isFBLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ColorConstants.kwhiteColor,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _isGoogleLoggedIn == false && _isFBLoggedIn == false
              ? FlutterLogo(size: 150,)
              : Container(),

          Center(
            child: _isGoogleLoggedIn == false
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      _isFBLoggedIn == false
                          ? _googleSignInButton()
                          : Container(),
                      SizedBox(height: 20),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Successfully Login with Google',
                        style: GoogleFonts.alata(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.kgreenColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        backgroundColor: ColorConstants.kgreyColor,
                        radius: 37,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            _googleSignIn.currentUser.photoUrl,
                          ),
                          radius: 35,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        _googleSignIn.currentUser.displayName,
                        style: GoogleFonts.alata(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.kblackColor,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _googleSignOutButton(),
                    ],
                  ),
          ),

          Center(
            child: _isFBLoggedIn == false
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SizedBox(height: 20),
                      _isGoogleLoggedIn == false
                          ? _facebookSignInButton()
                          : Container(),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Successfully Login with FaceBook',
                        style: GoogleFonts.alata(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.kgreenColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        backgroundColor: ColorConstants.kgreyColor,
                        radius: 37,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            userProfile["picture"]["data"]["url"],
                          ),
                          radius: 35,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        userProfile["name"],
                        style: GoogleFonts.alata(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.kblackColor,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _facebookSignOutButton(),
                    ],
                  ),
          ),



        ],
      ),
    );
  }

  Widget _googleSignInButton() {
    return OutlineButton(
      splashColor: ColorConstants.kgreyColor,
      onPressed: () {
        _googleLogin();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: ColorConstants.kgreyColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/images/google_logo.png"),
                height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: GoogleFonts.alata(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.kgreyColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _googleSignOutButton() {
    return OutlineButton(
      splashColor: ColorConstants.kgreyColor,
      onPressed: () {
        _googleLogout();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: ColorConstants.kgreyColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign out',
                style: GoogleFonts.alata(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.kgreyColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _facebookSignInButton() {
    return OutlineButton(
      splashColor: ColorConstants.kgreyColor,
      onPressed: () {
        _facebookLogin();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: ColorConstants.kgreyColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/images/facebook_logo.png"),
                height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with FB',
                style: GoogleFonts.alata(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.kgreyColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _facebookSignOutButton() {
    return OutlineButton(
      splashColor: ColorConstants.kgreyColor,
      onPressed: () {
        _facebookLogout();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: ColorConstants.kgreyColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign out',
                style: GoogleFonts.alata(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.kgreyColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}