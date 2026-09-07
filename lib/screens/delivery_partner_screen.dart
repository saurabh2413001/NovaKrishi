import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/localization.dart';


class DeliveryPartnerScreen extends StatelessWidget {
  const DeliveryPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: BrandWordmark(
                subtitle: AppStrings.t(
                  'DELIVERY PARTNER',
                  'डिलीवरी पार्टनर',
                ),
              ),
            ),


            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: appCardDecoration(),
                    child: Column(
                      children: [

                        const CircleAvatar(
                          radius: 35,
                          child: Icon(
                            Icons.local_shipping,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          AppStrings.t(
                            'Delivery Partner Dashboard',
                            'डिलीवरी पार्टनर डैशबोर्ड',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          AppStrings.t(
                            'Manage farm pickups, deliveries and earnings.',
                            'किसान पिकअप, डिलीवरी और कमाई संभालें।',
                          ),
                          textAlign: TextAlign.center,
                        ),

                      ],
                    ),
                  ),


                  const SizedBox(height:16),


                  _actionCard(
                    context,
                    Icons.inventory_2_outlined,
                    'Available Orders',
                    'उपलब्ध ऑर्डर',
                  ),


                  _actionCard(
                    context,
                    Icons.route_outlined,
                    'Active Delivery',
                    'चल रही डिलीवरी',
                  ),


                  _actionCard(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'Earnings',
                    'कमाई',
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }



  Widget _actionCard(
      BuildContext context,
      IconData icon,
      String en,
      String hi,
      ) {

    return Container(
      margin: const EdgeInsets.only(bottom:12),
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),


          const SizedBox(width:15),


          Expanded(
            child: Text(
              AppStrings.t(en,hi),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
          ),


          const Icon(
            Icons.arrow_forward_ios,
            size:16,
          )

        ],
      ),
    );
  }
}