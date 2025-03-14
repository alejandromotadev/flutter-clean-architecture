import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository productRepository;

  CreateProductUseCase(this.productRepository);

  Future<void> execute(Product product) async {
    return await productRepository.createProduct(product);
  }
}