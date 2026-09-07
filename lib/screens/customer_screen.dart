import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            BrandWordmark(
              subtitle: "FRESH FARM SHOPPING",
            ),

            const SizedBox(height:20),

            Text(
              "Farm Fresh Products",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height:12),


            Container(
              padding: const EdgeInsets.all(18),
              decoration: appCardDecoration(),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children:[

                  const Icon(
                    Icons.shopping_basket,
                    size:40,
                    color:AppColors.primary,
                  ),

                  const SizedBox(height:12),

                  const Text(
                    "Buy directly from farmers",
                    style:TextStyle(
                      fontSize:18,
                      fontWeight:FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height:8),

                  const Text(
                      "Fresh vegetables, grains and organic products directly from verified farms."
                  ),

                  const SizedBox(height:16),

                  ElevatedButton(
                    onPressed:(){},
                    child:
                    const Text("Explore Products"),
                  )

                ],
              ),
            ),


            const SizedBox(height:20),


            BenefitTile(
              icon:Icons.local_shipping,
              title:"Fast Delivery",
              subtitle:"Direct farm delivery",
            ),


            BenefitTile(
              icon:Icons.verified,
              title:"Verified Farmers",
              subtitle:"Trusted agriculture network",
            ),


            BenefitTile(
              icon:Icons.currency_rupee,
              title:"Fair Prices",
              subtitle:"No middlemen charges",
            )

          ],
        ),
      ),
    );
  }
}