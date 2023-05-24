import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> createProduct(Product product);
  Future<Product>getProductById(int id);
  Future<void>deleteProductById(Product product);
  Future<void>updateProductById(Product product);

}