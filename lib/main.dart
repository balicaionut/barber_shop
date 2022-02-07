import 'package:barber_shop/screens/booking_screen.dart';
import 'package:barber_shop/screens/home_screen.dart';
import 'package:barber_shop/screens/staff_home_screen.dart';
import 'package:barber_shop/screens/user_history_screen.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:barber_shop/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// Funcția Main
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase
  Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // Acest widget este rădăcina aplicației.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/staffHome':
            return PageTransition(
                settings: settings,
                child: StaffHome(),
                type: PageTransitionType.fade);
            break;
          case '/home':
            return PageTransition(
                settings: settings,
                child: HomePage(),
                type: PageTransitionType.fade);
            break;
          case '/history':
            return PageTransition(
                settings: settings,
                child: UserHistory(),
                type: PageTransitionType.fade);
            break;
          case '/booking':
            return PageTransition(
                settings: settings,
                child: BookingScreen(),
                type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  // Această metodă este reluată de fiecare dată când este apelat setState, de exemplu, așa cum este făcut
  // prin metoda _incrementCounter de mai sus.
  //
  // Cadrul Flutter a fost optimizat pentru a efectua din nou metode de compilare
  // rapid, astfel încât să puteți reconstrui doar orice lucru care trebuie actualizat
  // decât să trebuiască să schimbați individual instanțele widgeturilor.

  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Dacă userul nu este logat atunci se pornește pagina de login
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((firebaseUser) async {
        // Refresh stare
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        // Start ecran nou

        // Primește token aici
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e) {
        if (e is PlatformException) if (e.code ==
            FirebaseAuthUi.kUserCancelledError)
          ScaffoldMessenger.of(scaffoldState.currentContext)
              .showSnackBar(SnackBar(content: Text('${e.message}')));
        else
          ScaffoldMessenger.of(scaffoldState.currentContext)
              .showSnackBar(SnackBar(content: Text('Unknown error')));
      });
    } else {
      // Dacă userul este logat atunci se afișează pagina principală

    }
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return SafeArea(
        child: Scaffold(
      key: scaffoldState,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/my_bg.png'),
                fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: checkLoginState(context, false, scaffoldState),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  else {
                    var userState = snapshot.data as LOGIN_STATE;
                    if (userState == LOGIN_STATE.LOGGED) {
                      return Container();
                    } else {
                      // Dacă userul nu este logat deja atunci se afisează butonul de logare
                      return ElevatedButton.icon(
                        onPressed: () => processLogin(context),
                        icon: Icon(Icons.phone, color: Colors.white),
                        label: Text(
                          'LOGIN WITH PHONE',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black)),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    ));
  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    if (!context.read(forceReload).state) {
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3))
          .then((value) => {
                FirebaseAuth.instance.currentUser
                    .getIdToken()
                    .then((token) async {
                  // Dacă primim token atunci îl printăm
                  print('$token');
                  context.read(userToken).state = token;
                  // Check user in FireStore
                  CollectionReference userRef =
                      FirebaseFirestore.instance.collection('User');
                  DocumentSnapshot snapshotUser = await userRef
                      .doc(FirebaseAuth.instance.currentUser.phoneNumber)
                      .get();
                  // Forțează reîncărcare stare
                  context.read(forceReload).state = true;
                  if (snapshotUser.exists) {
                    // Și pentru că suntem deja logați pornim un nou ecran
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  } else {
                    // Dacă informațiile userului nu sunt disponibile atunci arată dialog
                    var nameController = TextEditingController();
                    var addressController = TextEditingController();
                    Alert(
                            context: context,
                            title: 'UPDATE PROFILES',
                            content: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.account_circle),
                                      labelText: 'Name'),
                                  controller: nameController,
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.home),
                                      labelText: 'Address'),
                                  controller: addressController,
                                )
                              ],
                            ),
                            buttons: [
                          DialogButton(
                              child: Text('CANCEL'),
                              onPressed: () => Navigator.pop(context)),
                          DialogButton(
                              child: Text('UPDATE'),
                              onPressed: () {
                                //Update to server
                                userRef
                                    .doc(FirebaseAuth
                                        .instance.currentUser.phoneNumber)
                                    .set({
                                  'name': nameController.text,
                                  'address': addressController.text
                                }).then((value) async {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                          scaffoldState.currentContext)
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                              'UPDATE PROFILES SUCCESSFULLY!')));
                                  await Future.delayed(Duration(seconds: 1),
                                      () {
                                    // Și pentru că suntem deja logați pornim un nou ecran
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/home', (route) => false);
                                  });
                                }).catchError((e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                          scaffoldState.currentContext)
                                      .showSnackBar(
                                          SnackBar(content: Text('$e')));
                                });
                              }),
                        ])
                        .show(); // Funcție care declanșează fereastra popup pentru completare date profil
                  }
                })
              });
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }
}
