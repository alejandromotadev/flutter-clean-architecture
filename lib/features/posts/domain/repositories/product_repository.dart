import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> createProduct(String name, String description, double price);

}