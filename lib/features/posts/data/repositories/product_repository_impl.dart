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
    return await productRemoteDataSource.updateProducts();
    return await productRemoteDataSource.deleteProducts();
    return await productRemoteDataSource.createProducts();

  }
}