import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/repositories/product_repository.dart';

class UpdateProductByIdUseCase {
  final ProductRepository productRepository;

  UpdateProductByIdUseCase(this.productRepository);

  Future<void> execute(Product product) async {
    return await productRepository.updateProductById(product);
  }
}