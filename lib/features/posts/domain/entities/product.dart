class Product {
  final int id;
  final String name;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
    // Método para convertir una nota en un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price
    };
  }

  // Método para crear una nota a partir de un mapa
  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price']
    );
  }
}
