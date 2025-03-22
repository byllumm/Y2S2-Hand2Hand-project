/* 
A class that represents a food item with various attributes such as
name, description, quantity, category, and type.

Methods:
[toMap]: Converts the [FoodItem] instance into a map representation.
[fromMap]: Creates a [FoodItem] instance from a map representation.
*/
class FoodItem {
  final int? id;
  final String name;
  final String description;
  final int quantity;
  final String category;
  final String type;

  FoodItem({
    this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.category,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'category': category,
      'type': type,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      category: map['category'],
      type: map['type'],
    );
  }
}
