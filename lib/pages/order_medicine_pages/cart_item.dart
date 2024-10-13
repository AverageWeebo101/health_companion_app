class CartItem {
  final String medicineId;
  final String medicineName;
  final String medicineBrand;
  final double medicinePrice;
  late final int quantity;

  CartItem({
    required this.medicineId,
    required this.medicineName,
    required this.medicineBrand,
    required this.medicinePrice,
    required this.quantity,
  });
}
