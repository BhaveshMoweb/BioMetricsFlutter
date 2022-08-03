import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalAuthentication auth = LocalAuthentication();
  late List<BiometricType> availableBiometrics = [];
  bool canAuthenticate = false;
  bool didAuthenticate = false;

  @override
  void initState() {
    getBiometricsData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(

            children: <Widget>[
              Flexible(
                child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableBiometrics.length,
                itemBuilder: (context, index) {
                  return Center(child: Text(availableBiometrics[index].name));
                }),
              ),
              /*widgetText(),*/
              TextButton(
                  onPressed: () async {
                    if (!didAuthenticate) {
                      try {
                        didAuthenticate = await auth.authenticate(
                            localizedReason:
                                'Please authenticate to show account balance',
                            options: const AuthenticationOptions(
                                useErrorDialogs: true));
                      } on PlatformException catch (e) {
                        if (e.code == auth_error.notEnrolled) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Finger Print not enrolled"),
                          ));
                        } else if (e.code == auth_error.lockedOut ||
                            e.code == auth_error.permanentlyLockedOut) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Bio Metrics Not Available"),
                          ));
                        } else if (e.code == auth_error.passcodeNotSet) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                "Device does not have hardware support for biometrics"),
                          ));
                        } else if (e.code == auth_error.notAvailable) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Bio Metrics Not Available"),
                          ));
                        }
                      }

                      setState(() {});
                    }
                  },
                  child: Text(didAuthenticate
                      ? "Authentication done"
                      : "Authenticate Here"))
            ],
          ),
        ));
  }

  Future<void> getBiometricsData() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    availableBiometrics = await auth.getAvailableBiometrics();

    setState(() {});
  }

  Widget widgetText() {
    for (BiometricType type in availableBiometrics) return Text(type.name);

    /*if (availableBiometrics.isNotEmpty) {
      for (BiometricType type in availableBiometrics) {
        if (availableBiometrics.contains(BiometricType.face)) {
          return const Text('Face Detection');
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          return const Text('Fingerprint');
        } else {
          return Text(type.name);
        }
      }
    } else {
      return TextButton(
        child: const Text("No Biometrics Found!"),
        onPressed: () {
          AppSettings.openLockAndPasswordSettings();
        },
      );
    }*/
    return const Text("No Biometrics Found");
  }
}
