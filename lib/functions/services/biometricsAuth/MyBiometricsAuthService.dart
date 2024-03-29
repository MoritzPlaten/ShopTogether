import 'package:local_auth/local_auth.dart';
import 'package:shopping_app/exceptions/MyCustomException.dart';
import 'package:local_auth_android/local_auth_android.dart';

class MyBiometricsAuthService {

  ///the function authenticate with faceId, fingerprint the user
  ///
  /// [MyCustomException] key words:
  /// - 'authentication-failed': the authentiation failed
  /// - 'weak': the authentication types are to weak
  /// - 'not-available': the authentification is not available
  Future<bool> authenticate() async {

    bool isAuthenticate = false;

    LocalAuthentication auth = LocalAuthentication();
    bool isBiometricsAvailable = await auth.canCheckBiometrics;
    bool isAuthenticateAvailable = isBiometricsAvailable || await auth.isDeviceSupported();

    if (!isAuthenticateAvailable) {

      throw MyCustomException("the authentification is not available!", "not-available");
    }

    List<BiometricType> biometricsOptions = await auth.getAvailableBiometrics();

    if (!biometricsOptions.contains(BiometricType.strong)) {

      throw MyCustomException("the authentication types are to weak", "weak");
    }

    try {

      isAuthenticate = await auth.authenticate(
          localizedReason: 'Bitte authentifizieren Sie sich, um sich anzumelden!',
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Biometrische Authentifzierung erforderlich!',
              cancelButton: 'Nein danke!',
            ),
          ],
          options: const AuthenticationOptions(
              biometricOnly: true,
              useErrorDialogs: false,
              stickyAuth: true
          ));

    } catch (e) {

      print(e);
      throw MyCustomException("the authentiation failed: $e", "authentication-failed");
    }

    return isAuthenticate;
  }

  static Future<bool> isBiometricsAvailableOnDevice() async {

    LocalAuthentication auth = LocalAuthentication();

    bool isBiometricsAvailable = await auth.canCheckBiometrics;

    late List<BiometricType> biometricsOptions;
    if (isBiometricsAvailable) {

      biometricsOptions = await auth.getAvailableBiometrics();
    }

    return isBiometricsAvailable && await auth.isDeviceSupported() && biometricsOptions != null && biometricsOptions.contains(BiometricType.strong);
  }
}