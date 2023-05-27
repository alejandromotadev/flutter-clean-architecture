import 'package:clean_architecture_bloc/features/posts/data/datasources/product_remote_data_source.dart';
import 'package:clean_architecture_bloc/features/posts/data/repositories/product_repository_impl.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/create_products_usecase.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/delete_products.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/get_products_usecase.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/update_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UseCaseConfig {
  GetProductsUseCase? getPostsUseCase;
  CreateProductUseCase? createProductUseCase;
  ProductRepositoryImpl? postRepositoryImpl;
  ProductRemoteDataSourceImp? postRemoteDataSourceImp;
  UpdateProductByIdUseCase? updateProductByIdUseCase;
  DeleteProductByIdUseCase? deleteProductUseCase;
  SharedPreferences? sharedPreferences;
  UseCaseConfig() {
    postRemoteDataSourceImp = ProductRemoteDataSourceImp(sharedPreferences: sharedPreferences!);
    postRepositoryImpl = ProductRepositoryImpl(productRemoteDataSource: postRemoteDataSourceImp!);
    getPostsUseCase = GetProductsUseCase(postRepositoryImpl!);
    updateProductByIdUseCase=UpdateProductByIdUseCase(postRepositoryImpl!);
    deleteProductUseCase=DeleteProductByIdUseCase(postRepositoryImpl!);
    createProductUseCase=CreateProductUseCase(postRepositoryImpl!);
  }
}