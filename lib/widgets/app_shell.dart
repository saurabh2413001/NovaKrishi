import '../models/models.dart';
import '../services/app_state.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/localization.dart';

import '../screens/home_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/prices_screen.dart';
import '../screens/ai_insights_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/farmer_buyer_offers_screen.dart';

import '../screens/customer_screen.dart';
import '../screens/buyer_offer_screen.dart';
import '../screens/delivery_partner_screen.dart';


class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}


class _AppShellState extends State<AppShell> {

  late int _index;
  late PageController _controller;


  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex;
    _controller = PageController(
      initialPage: _index,
    );

    appState.addListener(_refresh);
  }


  void _refresh(){
    setState(() {});
  }


  @override
  void dispose(){

    appState.removeListener(_refresh);

    _controller.dispose();

    super.dispose();
  }



  void _goTo(int index){

    setState(() {
      _index = index;
    });


    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds:250),
      curve: Curves.easeOut,
    );
  }



  @override
  Widget build(BuildContext context){


    final role = appState.role;



    /*
      Role based pages
    */


    List<Widget> pages = [];
    List<Map<String,dynamic>> tabs=[];



    if(role == KrishiRole.deliveryPartner){

      pages=[
        const DeliveryPartnerScreen(),
        const ProfileScreen(),
      ];


      tabs=[
        {
          "icon":Icons.local_shipping_outlined,
          "active":Icons.local_shipping,
          "title":AppStrings.t(
              "Delivery",
              "डिलीवरी"
          )
        },

        {
          "icon":Icons.person_outline,
          "active":Icons.person,
          "title":AppStrings.t(
              "Profile",
              "प्रोफ़ाइल"
          )
        },

      ];

    }


    else if(role == KrishiRole.bulkBuyer){


      pages=[

        const BuyerOfferScreen(),
        const ProfileScreen(),

      ];


      tabs=[

        {
          "icon":Icons.shopping_cart_outlined,
          "active":Icons.shopping_cart,
          "title":AppStrings.t(
              "Offers",
              "ऑफर"
          )
        },


        {
          "icon":Icons.person_outline,
          "active":Icons.person,
          "title":AppStrings.t(
              "Profile",
              "प्रोफ़ाइल"
          )
        },

      ];

    }


    else{


      pages=[

        HomeScreen(),
        MarketplaceScreen(),
        PricesScreen(),
        const FarmerBuyerOffersScreen(),
        AiInsightsScreen(),
        const ProfileScreen(),

      ];



      tabs=[

        {
          "icon":Icons.home_outlined,
          "active":Icons.home,
          "title":AppStrings.t(
              "Home",
              "होम"
          )
        },


        {
          "icon":Icons.storefront_outlined,
          "active":Icons.storefront,
          "title":AppStrings.t(
              "Market",
              "बाज़ार"
          )
        },


        {
          "icon":Icons.show_chart_outlined,
          "active":Icons.show_chart,
          "title":AppStrings.t(
              "Prices",
              "भाव"
          )
        },


        {
          "icon":Icons.local_offer_outlined,
          "active":Icons.local_offer,
          "title":AppStrings.t(
              "Buyer Offers",
              "खरीदार ऑफर"
          )
        },


        {
          "icon":Icons.auto_awesome_outlined,
          "active":Icons.auto_awesome,
          "title":AppStrings.t(
              "AI",
              "AI"
          )
        },


        {
          "icon":Icons.person_outline,
          "active":Icons.person,
          "title":AppStrings.t(
              "Profile",
              "प्रोफ़ाइल"
          )
        },


      ];


    }




    return Scaffold(

      body: SafeArea(

        child: PageView.builder(

          controller:_controller,

          itemCount: pages.length,


          onPageChanged:(i){

            setState(() {
              _index=i;
            });

          },


          itemBuilder:(context,i){

            return pages[i];

          },

        ),

      ),



      bottomNavigationBar: Container(

        decoration:BoxDecoration(

          color:AppColors.surface,

          border:Border(

            top:BorderSide(
              color:AppColors.border,
            ),

          ),

        ),


        child:SafeArea(

          child:SizedBox(

            height:65,


            child:Row(

              children:List.generate(

                tabs.length,


                    (i){

                  final active =
                      i==_index;



                  return Expanded(

                    child:InkWell(

                      onTap:(){

                        _goTo(i);

                      },


                      child:Column(

                        mainAxisAlignment:
                        MainAxisAlignment.center,


                        children:[


                          Icon(

                            active
                                ? tabs[i]["active"]
                                : tabs[i]["icon"],

                            color:active
                                ? AppColors.primaryDark
                                : AppColors.textMuted,

                          ),


                          const SizedBox(
                              height:3
                          ),


                          Text(

                            tabs[i]["title"],

                            style:TextStyle(

                              fontSize:10,

                              fontWeight:active
                                  ? FontWeight.bold
                                  : FontWeight.normal,


                              color:active
                                  ? AppColors.primaryDark
                                  : AppColors.textMuted,

                            ),

                          )


                        ],


                      ),

                    ),

                  );


                },


              ),

            ),


          ),

        ),

      ),


    );

  }

}