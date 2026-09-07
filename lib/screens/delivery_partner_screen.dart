import 'package:flutter/material.dart';

class DeliveryPartnerScreen extends StatelessWidget {
  const DeliveryPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Partner"),
      ),
      body: const Center(
        child: Text(
          "Delivery Dashboard\n\nRoutes + Earnings",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
