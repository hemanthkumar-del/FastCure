class MedicineModel {
  final String medicineId;
  final String name;
  final String manufacturer;
  final String dosage;
  final int stock;
  final double price;
  final String category;
  final String type; // Tablet, Capsule, Syrup, etc.

  MedicineModel({
    required this.medicineId,
    required this.name,
    required this.manufacturer,
    required this.dosage,
    required this.stock,
    required this.price,
    this.category = 'General',
    this.type = 'Tablet',
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      medicineId: id,
      name: map['name'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      dosage: map['dosage'] ?? '',
      stock: (map['stock'] ?? 0) as int,
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'General',
      type: map['type'] ?? 'Tablet',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'name': name,
      'manufacturer': manufacturer,
      'dosage': dosage,
      'stock': stock,
      'price': price,
      'category': category,
      'type': type,
    };
  }

  MedicineModel copyWith({
    String? medicineId,
    String? name,
    String? manufacturer,
    String? dosage,
    int? stock,
    double? price,
    String? category,
    String? type,
  }) {
    return MedicineModel(
      medicineId: medicineId ?? this.medicineId,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }
}
