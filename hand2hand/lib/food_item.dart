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
  final int quantity;
  final String action;


  FoodItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.action,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'action': action,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      action: map['action'],
    );
  }
}
