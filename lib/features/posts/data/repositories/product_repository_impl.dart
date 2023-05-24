import 'package:clean_architecture_bloc/features/posts/data/datasources/product_remote_data_source.dart';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource productRemoteDataSource;

  ProductRepositoryImpl({required this.productRemoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    //print('Repository');
    return await productRemoteDataSource.getProducts();

  }
  @override
  Future<Product> getProductById(int id) async {
    //print('Repository');
    return await productRemoteDataSource.getProductById(id);

  }
  @override
  Future<void>createProduct(Product product) async{
    return await productRemoteDataSource.createProduct(product);
  }
   @override
  Future<void> deleteProductById(Product product) async {
    //print('Repository');
    return await productRemoteDataSource.deleteProductById(product);

  }
   @override
  Future<void> updateProductById(Product product) async {
    //print('Repository');
    return await productRemoteDataSource.updateProductById(product);

  }
}