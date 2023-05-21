import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required int id,
    required String name,
    required String description,
    required int price
  }) : super(id: id, name: name, description: description, price: price);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price']
    );
  }

  factory ProductModel.fromEntity(Product post) {
    return ProductModel(
      id: post.id,
      name: post.name,
      description: post.description,
      price: post.price
    );
  }
}