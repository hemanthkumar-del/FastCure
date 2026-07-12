class MedicineModel {
  final String id;
  final String name;
  final String category;
  final String type; // Tablet, Capsule, Syrup, Inhaler
  final String stockStatus; // In Stock, Low Stock, Out of Stock
  final String dosageInstructions;

  MedicineModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.stockStatus,
    required this.dosageInstructions,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String medId) {
    return MedicineModel(
      id: medId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      stockStatus: map['stockStatus'] ?? 'In Stock',
      dosageInstructions: map['dosageInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'type': type,
      'stockStatus': stockStatus,
      'dosageInstructions': dosageInstructions,
    };
  }
}
