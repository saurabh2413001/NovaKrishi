import 'package:flutter/material.dart';

class BuyerOfferScreen extends StatefulWidget {
  const BuyerOfferScreen({super.key});

  @override
  State<BuyerOfferScreen> createState() => _BuyerOfferScreenState();
}

class _BuyerOfferScreenState extends State<BuyerOfferScreen> {

  final crop = TextEditingController();
  final qty = TextEditingController();
  final price = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buyer Crop Offer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: crop,
              decoration: const InputDecoration(
                labelText: "Crop Name",
                hintText: "Example: Wheat",
              ),
            ),

            const SizedBox(height:15),

            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Required Quantity",
                hintText: "Example: 500 Quintal",
              ),
            ),

            const SizedBox(height:15),

            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Offer Price",
                hintText: "₹ per Quintal",
              ),
            ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Offer Submitted Successfully"),
                  ),
                );
              },
              child: const Text("Submit Offer"),
            )

          ],
        ),
      ),
    );
  }
}
