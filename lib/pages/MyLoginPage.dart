import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/components/login/MyLoginWidget.dart';
import 'package:shopping_app/functions/MyFirebaseAuth.dart';
import 'package:shopping_app/functions/providers/login/MyLoginProvider.dart';
import 'package:shopping_app/functions/snackbars/MySnackBar.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _prenameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void refreshInputs() {

    _prenameController.text = "";
    _nameController.text = "";
    _passwordController.text = "";
    _confirmPasswordController.text = "";
    _emailController.text = "";
  }

  @override
  void initState() {
    super.initState();

    refreshInputs();
  }

  void updateToRegisterPage() {

    refreshInputs();

    List<TextEditingController> controllers = [_prenameController, _nameController, _emailController, _passwordController, _confirmPasswordController];

    List<bool> _showPassword = const [false, false, false, true, true];
    List<bool> showPassword = List.generate(controllers.length, (index) => _showPassword.elementAt(index));

    Provider.of<MyLoginProvider>(context, listen: false).updateShowPasswords(showPassword);


    Provider.of<MyLoginProvider>(context, listen: false).updateWidget(
        MyLoginWidget(
          title: "Registrierung",
          buttonFunctions: [_register, _toLogin],
          controllers: controllers,
          inputLabels: const ["Vorname*", "Nachname*", "E-Mail*", "Passwort*", "Passwort wiederholen*"],
          buttonLabels: const ["Registrieren", "Zur Anmeldung"],
          buttonForegroundColors: [Colors.white, Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.8)!],
          buttonBackgroundColors: [Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.8)!, Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.005)!],
          isInputPassword: _showPassword,
        )
    );
  }

  void updateToLoginPage() {

    refreshInputs();

    List<TextEditingController> controllers = [_emailController, _passwordController];

    List<bool> _showPassword = const [false, true];
    List<bool> showPassword = List.generate(controllers.length, (index) => _showPassword.elementAt(index));

    Provider.of<MyLoginProvider>(context, listen: false).updateShowPasswords(showPassword);


    Provider.of<MyLoginProvider>(context, listen: false).updateWidget(
        MyLoginWidget(
          title: "Anmeldung",
          buttonFunctions: [_login, _toRegister],
          controllers: controllers,
          inputLabels: const ["E-Mail*", "Passwort*"],
          buttonLabels: const ["Anmelden", "Zur Registrierung"],
          buttonForegroundColors: [Colors.white, Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.8)!],
          buttonBackgroundColors: [Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.8)!, Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.005)!],
          isInputPassword: const [false, true],
        )
    );
  }

  void _toRegister() async {

    updateToRegisterPage();
  }

  void _toLogin() async {

    //TODO: Nach EmailVerifizierung und Abbrechen, gibts ein State fehler

    updateToLoginPage();
  }

  Future<void> _login() async {

    bool error = false;

    if (_emailController.text == "" || _passwordController.text == "") {
      MySnackBar.showMySnackBar(context, 'Es müssen alle Felder mit "*" ausgefüllt werden!');
      error = true;
    }

    if (!error) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch(e) {

        if (e.code == 'user-not-found') { //TODO: Es kommt immer diese Fehlermeldung: INVALID_LOGIN_CREDENTIALS wenn User bei Anmeldung nicht vorhanden ist => user vorher überprüfen ob er vorhanden ist
          MySnackBar.showMySnackBar(context, 'Benutzer nicht gefunden.');
        } else if (e.code == 'wrong-password') {
          MySnackBar.showMySnackBar(context, 'Falsches Passwort.');
        } else if (e.code == 'user-disabled') {
          MySnackBar.showMySnackBar(context, 'Benutzerkonto deaktiviert.');
        } else if (e.code == 'too-many-requests') {
          MySnackBar.showMySnackBar(context, 'Zu viele Anfragen. Versuchen Sie es später erneut.');
        } else if (e.code == 'network-request-failed') {
          MySnackBar.showMySnackBar(context, 'Netzwerkfehler. Überprüfen Sie Ihre Internetverbindung.');
        } else if (e.code == 'invalid-email') {
          MySnackBar.showMySnackBar(context, 'Ungültiges E-Mail-Format. Bitte überprüfen Sie Ihre E-Mail-Adresse.');
        } else {
          MySnackBar.showMySnackBar(context, 'E-Mail ist nicht vorhanden oder Passwort ist falsch!');
          print("Firebase Error Code: ${e.code}");
        }

    } catch (e) {

        MySnackBar.showMySnackBar(context, 'Ein allgemeiner Fehler ist aufgetreten. Bitte kontaktieren Sie den Support!');
      }
    }
  }

  Future<void> _register() async {

    bool error = false;

    if (_passwordController.text == "" || _confirmPasswordController.text == "" || _prenameController.text == "" ||
        _nameController.text == "" || _emailController.text == "") {
      MySnackBar.showMySnackBar(context, 'Es müssen alle Felder mit "*" ausgefüllt werden!');
      error = true;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      MySnackBar.showMySnackBar(context, 'Die Felder "Passwort" und "Passwort wiederholen" stimmen nicht überein!');
      error = true;
    }

    if (!error) {

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text
        );

        userCredential.user!.sendEmailVerification();

        MySnackBar.showMySnackBar(context, 'Die Verifizierungs-E-Mail wurde versendet!', backgroundColor: Colors.blueGrey);

      } on FirebaseAuthException catch(e) {

        if (e.code == 'weak-password') {
          MySnackBar.showMySnackBar(context, 'Ihr Passwort ist zu schwach!');
        } else if (e.code == 'email-already-in-use') {
          MySnackBar.showMySnackBar(context, 'Die eingegebene E-Mail ist bereits vergeben!');
        } else if (e.code == 'invalid-email') {
          MySnackBar.showMySnackBar(context, 'Ungültiges E-Mail-Format. Bitte überprüfen Sie Ihre E-Mail-Adresse.');
        } else {
          MySnackBar.showMySnackBar(context, 'Ein Fehler ist aufgetreten. Bitte kontaktieren Sie den Support!');
        }

      } catch(e) {

        MySnackBar.showMySnackBar(context, 'Ein allgemeiner Fehler ist aufgetreten. Bitte kontaktieren Sie den Support!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        body: Stack(
          children: [

            Container(
            decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,),),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text(
                        "Einkaufsapp",
                        style: GoogleFonts.tiltNeon(
                            fontSize: 40,
                            backgroundColor: Colors.white
                        ),
                      ),
                      const SizedBox(height: 60,),

                      Consumer<MyLoginProvider>(
                          builder: (BuildContext context,
                              MyLoginProvider value,
                              Widget? child) {

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {

                                if (value.widget == null) {

                                  updateToLoginPage();
                                }
                              });
                            });

                            return SizedBox(
                              child: value.widget,
                            );
                          }),

                      const SizedBox(height: 60,)

                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
    );
  }
}