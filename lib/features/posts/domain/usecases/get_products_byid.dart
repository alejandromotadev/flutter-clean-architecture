import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/repositories/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository productRepository;

  GetProductByIdUseCase(this.productRepository);

  Future<Product> execute(int id) async {
    return await productRepository.getProductById(id);
  }
}