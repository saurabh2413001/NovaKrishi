import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/localization.dart';


class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.canvas,


      appBar: AppBar(

        title: Text(
          AppStrings.t(
            "Fresh Market",
            "ताज़ा मंडी",
          ),
        ),

        actions: [

          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),

            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(
              Icons.person_outline,
            ),

            onPressed: () {},
          ),

        ],

      ),



      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [



              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(20),

                decoration:
                BoxDecoration(

                  gradient:
                  LinearGradient(

                    colors: [

                      AppColors.primary,
                      AppColors.primary
                          .withOpacity(.75),

                    ],

                  ),

                  borderRadius:
                  BorderRadius.circular(22),

                ),


                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [


                    Text(

                      AppStrings.t(
                        "Buy directly from farmers",
                        "किसानों से सीधे खरीदें",
                      ),

                      style:
                      const TextStyle(

                        color: Colors.white,

                        fontSize: 22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),


                    const SizedBox(height:8),


                    Text(

                      AppStrings.t(
                        "Fresh vegetables, grains and fruits",
                        "ताज़ी सब्जियां, अनाज और फल",
                      ),

                      style:
                      const TextStyle(

                        color:
                        Colors.white70,

                      ),

                    ),



                    const SizedBox(height:18),


                    ElevatedButton(

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        Colors.white,

                        foregroundColor:
                        AppColors.primary,

                      ),

                      onPressed:(){},

                      child:
                      Text(

                        AppStrings.t(
                          "Explore Products",
                          "उत्पाद देखें",
                        ),

                      ),

                    )

                  ],

                ),

              ),



              const SizedBox(height:22),



              Text(

                AppStrings.t(
                  "Categories",
                  "श्रेणियां",
                ),

                style:
                const TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:12),



              Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [


                  _CategoryCard(
                    icon:Icons.eco,
                    title:"Vegetables",
                  ),


                  _CategoryCard(
                    icon:Icons.grain,
                    title:"Grains",
                  ),


                  _CategoryCard(
                    icon:Icons.apple,
                    title:"Fruits",
                  ),


                ],

              ),




              const SizedBox(height:24),




              Text(

                AppStrings.t(
                  "Popular Products",
                  "लोकप्रिय उत्पाद",
                ),

                style:
                const TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:12),



              _ProductCard(
                name:"Organic Wheat",
                price:"₹45/kg",
                farmer:"Ramesh Farm",
              ),


              _ProductCard(
                name:"Fresh Tomato",
                price:"₹30/kg",
                farmer:"Green Valley Farm",
              ),


              _ProductCard(
                name:"Fresh Milk",
                price:"₹55/L",
                farmer:"Village Dairy",
              ),


            ],

          ),

        ),

      ),

    );

  }

}





class _CategoryCard extends StatelessWidget {

  final IconData icon;

  final String title;


  const _CategoryCard({

    required this.icon,

    required this.title,

  });



  @override
  Widget build(BuildContext context) {


    return Container(

      width:95,

      padding:
      const EdgeInsets.all(12),

      decoration:
      BoxDecoration(

        color:Colors.white,

        borderRadius:
        BorderRadius.circular(18),

      ),


      child:
      Column(

        children: [


          Icon(

            icon,

            color:
            AppColors.primary,

            size:32,

          ),


          const SizedBox(height:8),


          Text(

            title,

            textAlign:
            TextAlign.center,

            style:
            const TextStyle(

              fontSize:12,

              fontWeight:
              FontWeight.w600,

            ),

          )


        ],

      ),

    );

  }

}





class _ProductCard extends StatelessWidget {


  final String name;

  final String price;

  final String farmer;



  const _ProductCard({

    required this.name,

    required this.price,

    required this.farmer,

  });



  @override
  Widget build(BuildContext context) {


    return Container(

      margin:
      const EdgeInsets.only(bottom:12),


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

        children: [


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
              Icons.shopping_basket,
              color:Colors.green,
            ),

          ),


          const SizedBox(width:14),


          Expanded(

            child:
            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [


                Text(

                  name,

                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize:16,

                  ),

                ),


                Text(

                  farmer,

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