import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'nefarious_remedies.dart';
import 'cart_item.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CheckoutPage({required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _contactNumberController =
      TextEditingController();
  bool isSeniorOrPWD = false;
  double vatRate = 0.12;
  double seniorPwdDiscount = 0.2;
  double baseDeliveryFee = 20;
  double distance = 0;
  bool isProcessing = false;
  String errorMessage = '';

  @override
  void dispose() {
    _contactNumberController.dispose();
    super.dispose();
  }

  double calculateTotal(List<CartItem> items) {
    double total = 0;
    for (var item in items) {
      total += item.medicinePrice * item.quantity;
    }
    return total;
  }

  double calculateVAT(double totalPrice) {
    return totalPrice * vatRate;
  }

  double calculateDiscount(double totalPrice) {
    return isSeniorOrPWD ? totalPrice * seniorPwdDiscount : 0;
  }

  double calculateDeliveryFee(double distance) {
    if (isSeniorOrPWD) {
      return 0;
    }
    return baseDeliveryFee + ((distance > 4) ? (distance - 4) * 5 : 0);
  }

  Future<void> checkout() async {
    setState(() {
      isProcessing = true;
    });

    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (CartItem item in widget.cartItems) {
        DocumentReference medicineRef = FirebaseFirestore.instance
            .collection('pharmacies')
            .doc('TT5akFCT2id9ZfZrJWcC')
            .collection('medicines')
            .doc(item.medicineId);

        DocumentSnapshot medicineSnapshot = await medicineRef.get();

        if (medicineSnapshot.exists) {
          int currentStock = int.parse(medicineSnapshot['medicine_stock']);
          int updatedStock = currentStock - item.quantity;

          if (updatedStock >= 0) {
            batch.update(
                medicineRef, {'medicine_stock': updatedStock.toString()});
          } else {
            throw Exception('Insufficient stock for ${item.medicineName}');
          }
        } else {
          throw Exception('Medicine not found: ${item.medicineName}');
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Checkout successful!'),
      ));

      Navigator.pop(context);
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred during checkout: $error';
      });
      print('Transaction failed: $error');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    bool isLoggedIn = user != null;
    double totalPrice = calculateTotal(widget.cartItems);
    double vatAmount = calculateVAT(totalPrice);
    double discountAmount = calculateDiscount(totalPrice);
    double deliveryFee = calculateDeliveryFee(distance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoggedIn)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text('No user data available');
                    }

                    var userData = snapshot.data!;
                    String displayName =
                        userData['name'] ?? 'No Name Available';
                    String contactNumber =
                        userData['contactNumber'] ?? 'No Contact Number';

                    return Text(
                      'Order For: $displayName\nProvided E-mail: ${user.email}\nContact Number: $contactNumber',
                      style: const TextStyle(fontSize: 18),
                    );
                  },
                ),
              if (!isLoggedIn)
                TextField(
                  controller: _contactNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Contact Number',
                    hintText: '09123456789',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                ),
              const SizedBox(height: 20),
              const Text(
                'Your Cart:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  CartItem item = widget.cartItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.medicineName} by ${item.medicineBrand}',
                              style: const TextStyle(fontSize: 16)),
                          Text(
                              'Price: ₱${item.medicinePrice} x ${item.quantity} = ₱${item.medicinePrice * item.quantity}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('Total Price: ₱$totalPrice',
                  style: const TextStyle(fontSize: 16)),
              Text('12% VAT: ₱$vatAmount',
                  style: const TextStyle(fontSize: 16)),
              if (isSeniorOrPWD)
                Text('Senior/PWD Discount: -₱$discountAmount',
                    style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                'Delivery Fee: ₱$deliveryFee (Base: ₱20, +₱5 per km after 4km)',
                style: const TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter distance (km)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          distance = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Final Total: ₱${(totalPrice + vatAmount - discountAmount + deliveryFee).toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: isSeniorOrPWD,
                    onChanged: (value) {
                      setState(() {
                        isSeniorOrPWD = value!;
                      });
                    },
                  ),
                  const Text('Senior Citizen or PWD'),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (!isLoggedIn && _contactNumberController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Please enter a contact number to proceed.')));
                      return;
                    }
                    await checkout();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Successful Delivery'),
                        duration: Duration(seconds: 2)));
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (r) => false);
                  },
                  child: const Text('Proceed Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
