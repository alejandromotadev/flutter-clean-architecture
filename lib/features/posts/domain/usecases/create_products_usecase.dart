import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository productRepository;

  CreateProductUseCase(this.productRepository);

  Future<Product> execute(String name, String description, double price) async {
    return await productRepository.createProduct(name, description, price);
  }
}