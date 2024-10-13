import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart_item.dart';
import 'checkout_page.dart';

class NefariousRemediesPage extends StatefulWidget {
  @override
  _NefariousRemediesPageState createState() => _NefariousRemediesPageState();
}

class _NefariousRemediesPageState extends State<NefariousRemediesPage> {
  List<CartItem> cart = [];
  double totalPrice = 0.0;
  int totalQuantity = 0;

  void addToCart(String medicineId, String medicineName, String medicineBrand,
      int quantity, double price, int stock) {
    if (quantity <= stock) {
      setState(() {
        var existingItem =
            cart.firstWhere((item) => item.medicineId == medicineId,
                orElse: () => CartItem(
                      medicineId: '',
                      medicineName: '',
                      medicineBrand: '',
                      medicinePrice: 0.0,
                      quantity: 0,
                    ));

        if (existingItem.medicineId != '') {
          existingItem.quantity += quantity;
        } else {
          cart.add(CartItem(
              medicineId: medicineId,
              medicineName: medicineName,
              medicineBrand: medicineBrand,
              medicinePrice: price,
              quantity: quantity));
        }

        totalQuantity += quantity;
        totalPrice += price * quantity;
      });
    } else {
      _showStockError();
    }
  }

  void _showStockError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stock Limit Exceeded'),
          content: const Text('You cannot add more than the available stock.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nefarious Remedies'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/health-companion-database.appspot.com/o/pharmacy_logos%2Fnefariousremedies_pharmacy_logo.png?alt=media&token=4cfff1c4-d7b9-4d64-ba2b-e69b2ac8dd85',
                height: screenSize.height * 0.2,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pharmacies')
                  .doc('TT5akFCT2id9ZfZrJWcC')
                  .collection('medicines')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final medicines = snapshot.data?.docs ?? [];

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (screenSize.width / 200).floor(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    var medicineId = medicine.id;
                    var medicineName = medicine['medicine_name'];
                    var medicineBrand = medicine['medicine_brand'];
                    var medicineImg = medicine['medicine_img'];
                    var medicinePrice =
                        double.parse(medicine['medicine_price']);
                    var medicineStock = int.parse(medicine['medicine_stock']);

                    TextEditingController _quantityController =
                        TextEditingController();

                    return Card(
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(medicineImg,
                              height: 100, fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(medicineName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('By: $medicineBrand'),
                                Text('₱${medicinePrice.toStringAsFixed(2)}'),
                                Text('Stock: $medicineStock'),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _quantityController,
                                        decoration: const InputDecoration(
                                            labelText: 'Qty'),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        int quantity = int.tryParse(
                                                _quantityController.text) ??
                                            0;
                                        if (quantity > 0) {
                                          addToCart(
                                              medicineId,
                                              medicineName,
                                              medicineBrand,
                                              quantity,
                                              medicinePrice,
                                              medicineStock);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity: $totalQuantity',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'Total: ₱${totalPrice.toStringAsFixed(2)} (Not Final Price)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CheckoutPage(cartItems: cart)),
                    );
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
