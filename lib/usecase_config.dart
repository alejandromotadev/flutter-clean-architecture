import 'package:clean_architecture_bloc/features/posts/data/datasources/product_remote_data_source.dart';
import 'package:clean_architecture_bloc/features/posts/data/repositories/product_repository_impl.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/get_products_usecase.dart';

class UsecaseConfig {
  GetProductsUseCase? getPostsUsecase;
  ProductRepositoryImpl? postRepositoryImpl;
  ProductRemoteDataSourceImp? postRemoteDataSourceImp;

  UsecaseConfig() {
    postRemoteDataSourceImp = ProductRemoteDataSourceImp();
    postRepositoryImpl = ProductRepositoryImpl(productRemoteDataSource: postRemoteDataSourceImp!);
    getPostsUsecase = GetProductsUseCase(postRepositoryImpl!);
  }
}