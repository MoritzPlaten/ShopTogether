import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_app/exceptions/MyCustomException.dart';
import 'package:shopping_app/functions/services/biometricsAuth/MyBiometricsAuthService.dart';
import 'package:shopping_app/functions/services/snackbars/MySnackBarService.dart';
import 'package:shopping_app/functions/services/storage/MySecureStorageService.dart';
import 'package:shopping_app/objects/users/MyDefaultUserStructure.dart';

class MyBiometricsLogin {

  ///gets the local user infos from the secure storage if the authentication was successfully
  ///[MyCustomException] Keys:
  ///- authentication-failed
  ///- weak
  ///- not-available
  static Future<MyDefaultUserStructure> getUserDataFromBiometrics() async {

    late bool isAuthenticate;
    MyBiometricsAuthService myBiometricsAuthService = MyBiometricsAuthService();
    try {

      isAuthenticate = await myBiometricsAuthService.authenticate();
    } on MyCustomException catch(e) {

      isAuthenticate = false;
      throw MyCustomException(e.message, e.keyword);
    }

    MySecureStorageService mySecureStorageService = MySecureStorageService();
    ///TODO: Hier gibts probleme, als wurde kein Biometrics stattfinden
    if (isAuthenticate) {

      return mySecureStorageService.getUserFromStorage();
    }

    return MyDefaultUserStructure(
        email: "",
        password: ""
    );
  }

  /// This function logged in the user with biometrics automatically
  ///
  /// [MyCustomException] Keys:
  /// - email-password-null: email or password are null!
  /// - email-password-empty: email or password are empty!
  static void loginWithBiometrics(BuildContext context) async {

    MySecureStorageService mySecureStorageService = MySecureStorageService();
    if (mySecureStorageService.isBiometricActive() != null || mySecureStorageService.isBiometricActive() as bool) {
      ///TODO: hier
    }

    MyDefaultUserStructure myUser;
    try {

      myUser = await getUserDataFromBiometrics();
      print(myUser.email! + " " + myUser.password!);

      if (myUser.email == null || myUser.password == null) {

        throw MyCustomException("email or password are null!", "email-password-null");
      }

      if (myUser.email == "" || myUser.password == "") {

        throw MyCustomException("email or password are empty!", "email-password-empty");
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: myUser.email!, password: myUser.password!);

    } on MyCustomException catch(e) {

      switch(e.keyword) {

        case "authentication-failed":

          print("Authentication Failed!");
          print(e.message);
          break;
        case "weak":

          MySnackBarService.showMySnackBar(context, "Ihr Gerät besitzt keine FaceId/Fingerprint!");
          break;
        case "not-available":

          print("Authentication not available");
          break;
      }
    } on FirebaseException catch (firebaseEx) {

        throw MyCustomException(firebaseEx.message == null ? "" : firebaseEx.message!, firebaseEx.code);
      }
  }
}