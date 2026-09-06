import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/app_theme.dart';
import '../../services/localization.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../../widgets/app_shell.dart';

class GoogleSignInScreen extends StatefulWidget { const GoogleSignInScreen({super.key}); @override State<GoogleSignInScreen> createState()=>_GoogleSignInScreenState(); }
class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  bool _loading=false;
  static const _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '786093457045-m24k5id88m2314srvkv1fb9r9877tsit.apps.googleusercontent.com',
  );
  Future<void> _continue() async {
    setState(()=>_loading=true);
    try {
      final google=GoogleSignIn.instance;
      await google.initialize(serverClientId: _serverClientId);
      final account=await google.authenticate();
      final idToken=account.authentication.idToken;
      if (idToken==null || idToken.isEmpty) throw Exception('Google ID token was not returned.');
      final result=await const ApiService().googleSignIn(idToken);
      final user=result['user'];
      if (user is Map) appState.setUser(Map<String,dynamic>.from(user));
      if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=>AppShell()),(r)=>false);
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ',''))));
    } finally { if(mounted) setState(()=>_loading=false); }
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(AppStrings.t('Continue with Google','Google से जारी रखें'))),body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:430),child:Column(children:[
    Container(width:72,height:72,decoration:BoxDecoration(color:Colors.white,shape:BoxShape.circle,border:Border.all(color:AppColors.border)),child:const Center(child:Text('G',style:TextStyle(fontSize:32,fontWeight:FontWeight.w800)))),
    const SizedBox(height:20),Text(AppStrings.t('Sign in securely','सुरक्षित रूप से साइन इन करें'),style:Theme.of(context).textTheme.displaySmall,textAlign:TextAlign.center),
    const SizedBox(height:8),Text(AppStrings.t('Use your Google account to continue to NovaKrishi.','NovaKrishi जारी रखने के लिए अपने Google अकाउंट का उपयोग करें.'),textAlign:TextAlign.center),
    const SizedBox(height:22),SizedBox(width:double.infinity,child:ElevatedButton.icon(onPressed:_loading?null:_continue,icon:_loading?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Icon(Icons.g_mobiledata,size:26),label:Text(_loading?AppStrings.t('Connecting…','कनेक्ट हो रहा है…'):AppStrings.t('Continue with Google','Google से जारी रखें')))),
    const SizedBox(height:10),TextButton(onPressed:()=>Navigator.of(context).maybePop(),child:Text(AppStrings.t('Use another sign-in method','दूसरे साइन-इन तरीके का उपयोग करें'))),
  ])))));
}
