import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/localization.dart';


class BuyerOfferScreen extends StatefulWidget {

  const BuyerOfferScreen({
    super.key,
  });


  @override
  State<BuyerOfferScreen> createState() =>
      _BuyerOfferScreenState();

}



class _BuyerOfferScreenState
    extends State<BuyerOfferScreen> {


  final crop = TextEditingController();

  final qty = TextEditingController();

  final price = TextEditingController();



  @override
  void dispose(){

    crop.dispose();
    qty.dispose();
    price.dispose();

    super.dispose();

  }



  void submitOffer(){

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(
          AppStrings.t(
            "Crop demand posted successfully",
            "फसल मांग सफलतापूर्वक पोस्ट हुई",
          ),
        ),
      ),

    );

  }



  @override
  Widget build(BuildContext context){


    return Scaffold(

      backgroundColor:
      AppColors.canvas,


      appBar:
      AppBar(

        title:
        Text(

          AppStrings.t(
            "Buyer Dashboard",
            "खरीदार डैशबोर्ड",
          ),

        ),

        actions:[

          IconButton(
            icon:
            const Icon(
              Icons.notifications_none,
            ),

            onPressed:(){},

          )

        ],

      ),



      body:

      SafeArea(

        child:

        SingleChildScrollView(

          padding:
          const EdgeInsets.all(16),


          child:

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children:[



              Container(

                width:
                double.infinity,


                padding:
                const EdgeInsets.all(20),


                decoration:
                BoxDecoration(

                  gradient:
                  LinearGradient(

                    colors:[

                      AppColors.primary,

                      AppColors.primary
                          .withOpacity(.75),

                    ],

                  ),


                  borderRadius:
                  BorderRadius.circular(22),

                ),



                child:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[


                    Text(

                      AppStrings.t(
                        "Buy directly from farmers",
                        "किसानों से सीधे खरीदें",
                      ),

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(height:8),



                    Text(

                      AppStrings.t(
                        "Create bulk crop requirements and receive farmer offers",
                        "अपनी बड़ी फसल जरूरत पोस्ट करें और किसानों से ऑफर पाएं",
                      ),

                      style:
                      const TextStyle(

                        color:
                        Colors.white70,

                      ),

                    ),

                  ],

                ),

              ),




              const SizedBox(height:24),




              Text(

                AppStrings.t(
                  "Post New Requirement",
                  "नई आवश्यकता पोस्ट करें",
                ),

                style:
                const TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:12),




              _InputCard(

                child:
                TextField(

                  controller:
                  crop,

                  decoration:
                  InputDecoration(

                    prefixIcon:
                    const Icon(
                      Icons.eco,
                    ),

                    labelText:
                    AppStrings.t(
                      "Crop Name",
                      "फसल का नाम",
                    ),

                    hintText:
                    "Wheat, Rice",

                    border:
                    InputBorder.none,

                  ),

                ),

              ),



              const SizedBox(height:12),



              _InputCard(

                child:
                TextField(

                  controller:
                  qty,

                  keyboardType:
                  TextInputType.number,


                  decoration:
                  InputDecoration(

                    prefixIcon:
                    const Icon(
                      Icons.inventory,
                    ),

                    labelText:
                    AppStrings.t(
                      "Required Quantity",
                      "जरूरी मात्रा",
                    ),

                    hintText:
                    "500 Quintal",

                    border:
                    InputBorder.none,

                  ),

                ),

              ),




              const SizedBox(height:12),




              _InputCard(

                child:
                TextField(

                  controller:
                  price,

                  keyboardType:
                  TextInputType.number,


                  decoration:
                  InputDecoration(

                    prefixIcon:
                    const Icon(
                      Icons.currency_rupee,
                    ),

                    labelText:
                    AppStrings.t(
                      "Offer Price",
                      "ऑफर कीमत",
                    ),

                    hintText:
                    "₹ per Quintal",

                    border:
                    InputBorder.none,

                  ),

                ),

              ),




              const SizedBox(height:20),





              SizedBox(

                width:
                double.infinity,


                child:
                ElevatedButton.icon(

                  onPressed:
                  submitOffer,


                  icon:
                  const Icon(
                    Icons.send,
                  ),


                  label:
                  Text(

                    AppStrings.t(
                      "Submit Requirement",
                      "जरूरत भेजें",
                    ),

                  ),

                ),

              ),




              const SizedBox(height:28),





              Text(

                AppStrings.t(
                  "Active Requirements",
                  "चल रही आवश्यकताएं",
                ),

                style:
                const TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:12),



              _OfferCard(
                crop:"Wheat",
                quantity:"500 Quintal",
                price:"₹2400/Q",
              ),


              _OfferCard(
                crop:"Rice",
                quantity:"300 Quintal",
                price:"₹3200/Q",
              ),



            ],

          ),

        ),

      ),

    );

  }

}




class _InputCard extends StatelessWidget {


  final Widget child;


  const _InputCard({

    required this.child,

  });



  @override
  Widget build(BuildContext context){

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal:12,
      ),


      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(16),

      ),


      child:
      child,

    );

  }

}




class _OfferCard extends StatelessWidget {


  final String crop;

  final String quantity;

  final String price;



  const _OfferCard({

    required this.crop,

    required this.quantity,

    required this.price,

  });



  @override
  Widget build(BuildContext context){


    return Container(

      margin:
      const EdgeInsets.only(
        bottom:12,
      ),


      padding:
      const EdgeInsets.all(16),


      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(18),

      ),


      child:
      Row(

        children:[


          Container(

            width:55,

            height:55,


            decoration:
            BoxDecoration(

              color:
              AppColors.mintTint,

              borderRadius:
              BorderRadius.circular(14),

            ),


            child:
            const Icon(
              Icons.local_shipping,
              color:
              Colors.green,
            ),

          ),


          const SizedBox(width:14),



          Expanded(

            child:
            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children:[


                Text(

                  crop,

                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize:16,

                  ),

                ),


                Text(
                  quantity,
                  style:
                  TextStyle(
                    color:
                    AppColors.textMuted,
                  ),
                ),

              ],

            ),

          ),



          Text(

            price,

            style:
            TextStyle(

              color:
              AppColors.primary,

              fontWeight:
              FontWeight.bold,

            ),

          )


        ],

      ),

    );

  }

}