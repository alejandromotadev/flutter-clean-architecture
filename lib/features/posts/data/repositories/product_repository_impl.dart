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
  Future<Product>createProduct(String name, String description, double price) async{
    return await productRemoteDataSource.createProduct(name, description, price);
  }
}