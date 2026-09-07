import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/localization.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/app_shell.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';

import '../customer_screen.dart';
import '../buyer_offer_screen.dart';
import '../delivery_partner_screen.dart';


class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final KrishiRole role;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
    required this.role,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}


class _OtpVerificationScreenState extends State<OtpVerificationScreen> {

static const int _codeLength = 6;

final List<String> _digits =
List.filled(_codeLength, '');

int _secondsLeft = 45;

Timer? _timer;

double _gap = 8;

final ApiService _api = ApiService();



@override
void initState() {
super.initState();
_startTimer();
}



void _startTimer() {

_timer?.cancel();

_timer = Timer.periodic(
const Duration(seconds: 1),
(timer) {

if (_secondsLeft == 0) {
timer.cancel();
return;
}

setState(() {
_secondsLeft--;
});

},
);
}



@override
void dispose() {

_timer?.cancel();

super.dispose();
}



int get _nextEmptyIndex =>
_digits.indexOf('');



void _onKeyTap(String key) {

setState(() {

if(key == 'back'){

for(int i=_codeLength-1;i>=0;i--){

if(_digits[i].isNotEmpty){

_digits[i]='';
break;

}
}

return;
}


final index=_nextEmptyIndex;


if(index!=-1){

_digits[index]=key;

}


});

}




bool get _isComplete =>
_digits.every((e)=>e.isNotEmpty);




String get _otp =>
_digits.join();





Future<void> _verifyOtp() async {


try {


final result = await _api.verifyOtp(
widget.mobileNumber.replaceAll(' ',''),
_otp,
);



final user=result['user'];



if(user is Map){

appState.setUser(
Map<String,dynamic>.from(user),
role: widget.role,
);

}



if(!mounted)return;



Widget nextScreen;



switch(widget.role){


case KrishiRole.farmer:

  nextScreen = AppShell();
break;



case KrishiRole.customer:

nextScreen = const CustomerScreen();

break;



case KrishiRole.bulkBuyer:

nextScreen = const BuyerOfferScreen();

break;



case KrishiRole.deliveryPartner:

nextScreen = const DeliveryPartnerScreen();

break;


}



Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder:(context)=>nextScreen,
),
(route)=>false,
);



}

on ApiException catch(e){


if(!mounted)return;


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(
content:Text(e.message),
),

);

}

catch(e){


if(!mounted)return;


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(
content:Text(
'Unable to connect to NovaKrishi server.'
),
),

);

}


}
@override
Widget build(BuildContext context) {

  return Scaffold(

    appBar: AppBar(
      title: const Text('NovaKrishi'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
    ),

    body: SafeArea(

      child: ListView(

        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          16,
        ),

        children: [


          ProgressHeader(
            eyebrow: 'Verify identity',
            step: AppStrings.t(
              'STEP 2 OF 2',
              'चरण 2 / 2',
            ),
            progress: 1,
          ),


          const SizedBox(height:20),



          Center(

            child: Container(

              width:60,
              height:60,

              decoration:BoxDecoration(
                color:AppColors.mintTint,
                shape:BoxShape.circle,
              ),


              child:Icon(
                Icons.lock_outline,
                color:AppColors.primary,
                size:28,
              ),

            ),

          ),



          const SizedBox(height:14),



          Text(

            AppStrings.t(
              'Verify Mobile Number',
              'मोबाइल नंबर सत्यापित करें',
            ),

            textAlign:TextAlign.center,

            style:
            Theme.of(context)
                .textTheme
                .displaySmall,

          ),



          const SizedBox(height:8),




          Text(

            '${AppStrings.t(
              'Enter the 6-digit OTP sent to',
              'आपके मोबाइल पर भेजा गया 6-अंकीय OTP दर्ज करें',
            )}\n\n+91 ${widget.mobileNumber}',


            textAlign:TextAlign.center,


            style:TextStyle(
              color:AppColors.textSecondary,
            ),

          ),




          const SizedBox(height:22),




          LayoutBuilder(

            builder:(context,constraints){


              _gap=8;


              final size =
              ((constraints.maxWidth -
                  (_gap*5))/6)
                  .clamp(38.0,48.0);



              return Row(

                mainAxisAlignment:
                MainAxisAlignment.center,


                children:[


                  for(int i=0;i<_codeLength;i++)

                    ...[

                      _OtpBox(

                        value:_digits[i],

                        active:
                        i==_nextEmptyIndex,

                        size:size,

                      ),


                      if(i!=_codeLength-1)

                        SizedBox(
                          width:_gap,
                        )

                    ]


                ],

              );


            },

          ),




          const SizedBox(height:14),




          Center(

            child:Text(

              _secondsLeft>0

                  ? 'Resend code in $_secondsLeft seconds'

                  : "Didn't receive OTP?",


              style:TextStyle(

                fontSize:12,

                color:
                AppColors.textMuted,

              ),

            ),

          ),





          const SizedBox(height:20),




          ElevatedButton(


            onPressed:
            _isComplete
                ? _verifyOtp
                : null,


            child:Row(

              mainAxisAlignment:
              MainAxisAlignment.center,


              children:[


                Text(
                  AppStrings.t(
                    'Verify & Continue',
                    'सत्यापित करें और जारी रखें',
                  ),
                ),



                const SizedBox(width:8),



                const Icon(
                  Icons.arrow_forward,
                  size:18,
                ),


              ],

            ),


          ),





          const SizedBox(height:18),




          _NumericKeypad(
            onKeyTap:_onKeyTap,
          ),




          const SizedBox(height:20),




          Row(

            mainAxisAlignment:
            MainAxisAlignment.center,


            children:[

              Icon(
                Icons.shield_outlined,
                size:13,
                color:AppColors.textMuted,
              ),


              const SizedBox(width:4),


              Flexible(

                child:Text(

                  AppStrings.t(
                    'Never share your OTP with anyone.',
                    'अपना OTP किसी से साझा न करें।',
                  ),

                  textAlign:
                  TextAlign.center,


                  style:const TextStyle(
                    fontSize:11,
                  ),

                ),

              )

            ],

          ),




          const SizedBox(height:10),


          const SizedBox(height: 20),
        ],

      ),

    ),

  );

}

}



class _OtpBox extends StatelessWidget {


  final String value;

  final bool active;

  final double size;



  const _OtpBox({

    required this.value,

    required this.active,

    this.size=42,

  });



  @override
  Widget build(BuildContext context){


    return Container(

      width:size,

      height:size+8,


      alignment:Alignment.center,


      decoration:BoxDecoration(

        color:AppColors.canvas,


        borderRadius:
        BorderRadius.circular(
          AppRadii.sm,
        ),



        border:Border.all(

          color:

          active

              ? AppColors.primary

              : AppColors.border,


          width:

          active

              ? 1.6

              : 1,

        ),

      ),



      child:

      value.isEmpty

          ?

      active

          ? Container(

        width:2,

        height:22,

        color:AppColors.primary,

      )

          : const SizedBox.shrink()



          :

      Text(

        value,

        style:const TextStyle(

          fontSize:20,

          fontWeight:
          FontWeight.w800,

        ),

      ),


    );

  }


}
class _NumericKeypad extends StatelessWidget {

  final ValueChanged<String> onKeyTap;


  const _NumericKeypad({
    required this.onKeyTap,
  });



  static const List<List<String>> _rows = [

    ['1','2','3'],

    ['4','5','6'],

    ['7','8','9'],

    ['','0','back'],

  ];



  @override
  Widget build(BuildContext context){


    return LayoutBuilder(

      builder:(context,constraints){


        final width =
        ((constraints.maxWidth - 32) / 3)
            .clamp(48.0,72.0);



        return Column(

          children:[


            for(final row in _rows)


              Padding(

                padding:
                const EdgeInsets.only(
                  bottom:8,
                ),



                child:Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,


                  children:[


                    for(int i=0;i<row.length;i++)


                      ...[


                        _KeypadButton(

                          label:row[i],

                          width:width,

                          onTap:onKeyTap,

                        ),



                        if(i!=row.length-1)

                          const SizedBox(
                            width:8,
                          ),


                      ]

                  ],

                ),

              )

          ],

        );


      },

    );


  }

}





class _KeypadButton extends StatelessWidget {


  final String label;

  final double width;

  final ValueChanged<String> onTap;



  const _KeypadButton({

    required this.label,

    required this.width,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context){



    if(label.isEmpty){

      return SizedBox(

        width:width,

        height:52,

      );

    }




    return SizedBox(

      width:width,

      height:52,


      child:Material(

        color:AppColors.canvas,


        borderRadius:
        BorderRadius.circular(
          AppRadii.sm,
        ),



        child:InkWell(

          borderRadius:
          BorderRadius.circular(
            AppRadii.sm,
          ),



          onTap:(){

            onTap(label);

          },



          child:Center(


            child:

            label=='back'


                ?

            const Icon(
              Icons.backspace_outlined,
              size:18,
            )


                :

            Text(

              label,


              style:const TextStyle(

                fontSize:18,

                fontWeight:
                FontWeight.w600,

              ),

            ),


          ),

        ),

      ),

    );


  }

}