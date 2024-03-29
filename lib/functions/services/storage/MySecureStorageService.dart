import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopping_app/exceptions/MyCustomException.dart';
import 'package:shopping_app/functions/services/storage/MyStorageKeys.dart';
import 'package:shopping_app/objects/users/MyDefaultUserStructure.dart';

class MySecureStorageService {

  /// For this function, the user must enter their e-mail address and password in order to enter it in the memory.
  ///
  /// [MyCustomException] key words:
  /// - 'login-wrong': the login inputs are wrong
  /// - 'email-not-verified': the email is not verified
  /// - 'not-logged-in': the user is not logged in
  void updateUserInStorage(String email, String password) async {

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw MyCustomException("the user is not logged in!", "not-logged-in");
    }

    if (user.emailVerified == false) {
      throw MyCustomException("the email address is not verified!", "email-not-verified");
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try { await user.reauthenticateWithCredential(credential); } catch (e) {
      throw MyCustomException("the login inputs are wrong: $e!", "login-wrong");
    }

    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    await storage.write(
        key: MyStorageKeys.emailAdress,
        value: email
    );
    await storage.write(
        key: MyStorageKeys.password,
        value: password
    );
  }

  Future<MyDefaultUserStructure> getUserFromStorage() async {

    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    String? emailAddress = await storage.read(key: MyStorageKeys.emailAdress);
    String? password = await storage.read(key: MyStorageKeys.password);

    return MyDefaultUserStructure(
        email: emailAddress,
        password: password
    );
  }

  void deleteUsers() async {

    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    await storage.deleteAll();
  }

  void updateIsBiometricActive(String value) async {

    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    await storage.write(
        key: 'isBiometricsActive',
        value: value
    );
  }

  Future<String?> isBiometricActive() async {

    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    String? isBiometricActive = await storage.read(
        key: 'isBiometricsActive',
    );

    return isBiometricActive;
  }
}