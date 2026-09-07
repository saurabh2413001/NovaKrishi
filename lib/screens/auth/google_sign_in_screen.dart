import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../services/localization.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../../widgets/app_shell.dart';


class GoogleSignInScreen extends StatefulWidget {

  final KrishiRole role;

  const GoogleSignInScreen({
    super.key,
    required this.role,
  });


  @override
  State<GoogleSignInScreen> createState() =>
      _GoogleSignInScreenState();
}



class _GoogleSignInScreenState
    extends State<GoogleSignInScreen> {


  bool _loading = false;


  static const _serverClientId =
  String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
    '786093457045-m24k5id88m2314srvkv1fb9r9877tsit.apps.googleusercontent.com',
  );



  Future<void> _continue() async {

    setState(() {
      _loading = true;
    });


    try {


      final google = GoogleSignIn.instance;


      await google.initialize(
        serverClientId: _serverClientId,
      );



      final account =
      await google.authenticate();



      final idToken =
          account.authentication.idToken;



      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          "Google token missing",
        );
      }



      final result =
      await const ApiService()
          .googleSignIn(idToken);



      final user = result['user'];



      if (user is Map) {

        appState.setUser(
          Map<String,dynamic>.from(user),
          role: widget.role,
        );

      }



      appState.setRole(
        widget.role,
      );



      debugPrint(
        "GOOGLE LOGIN ROLE = ${appState.role}",
      );



      if (!mounted) return;



      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) => AppShell(),
        ),

            (route)=>false,
      );



    }

    catch(e){


      if(mounted){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content:
            Text(
              e.toString(),
            ),
          ),

        );

      }

    }


    finally{

      if(mounted){

        setState(() {
          _loading=false;
        });

      }

    }


  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar:
      AppBar(
        title:
        Text(
          AppStrings.t(
            "Continue with Google",
            "Google से जारी रखें",
          ),
        ),
      ),



      body:
      Center(

        child:
        ElevatedButton.icon(

          onPressed:
          _loading
              ? null
              : _continue,


          icon:
          const Icon(
            Icons.g_mobiledata,
          ),


          label:
          Text(

            _loading
                ?
            "Connecting..."
                :
            AppStrings.t(
              "Continue with Google",
              "Google से जारी रखें",
            ),

          ),

        ),

      ),


    );

  }

}