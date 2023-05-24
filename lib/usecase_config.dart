import 'package:clean_architecture_bloc/features/posts/data/datasources/product_remote_data_source.dart';
import 'package:clean_architecture_bloc/features/posts/data/repositories/product_repository_impl.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/create_products_usecase.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/delete_products.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/get_products_usecase.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/update_products.dart';

class UsecaseConfig {
  GetProductsUseCase? getPostsUsecase;
  CreateProductUseCase? createProductUseCase;
  ProductRepositoryImpl? postRepositoryImpl;
  ProductRemoteDataSourceImp? postRemoteDataSourceImp;
  UpdateProductByIdUseCase? updateProductByIdUseCase;
  DeleteProductByIdUseCase? deleteProductUsecase;

  UsecaseConfig() {
    postRemoteDataSourceImp = ProductRemoteDataSourceImp();
    postRepositoryImpl = ProductRepositoryImpl(productRemoteDataSource: postRemoteDataSourceImp!);
    getPostsUsecase = GetProductsUseCase(postRepositoryImpl!);
    updateProductByIdUseCase=UpdateProductByIdUseCase(postRepositoryImpl!);
    deleteProductUsecase=DeleteProductByIdUseCase(postRepositoryImpl!);
    createProductUseCase=CreateProductUseCase(postRepositoryImpl!);
  }
}