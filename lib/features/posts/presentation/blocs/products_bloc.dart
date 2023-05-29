import 'package:clean_architecture_bloc/features/posts/data/datasources/product_remote_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/create_products_usecase.dart';
import 'package:meta/meta.dart';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/get_products_usecase.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/delete_products.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/update_products.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getPostsUseCase;
  final ProductRemoteDataSource remoteDataSource;
  ProductsBloc({required this.getPostsUseCase, required this.remoteDataSource})
      : super(Loading()) {
    on<ProductsEvent>((event, emit) async {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        if (event is InitialState) {
          try {
            List<Product> response = await getPostsUseCase.execute();
            emit(Loaded(products: response));
          } catch (e) {
            emit(Error(error: e.toString()));
          }
        }
      } else {
        if (event is InitialState) {
          try {
            List<Product> response = await getPostsUseCase.execute();
            emit(LoadedOffline(productsOffline: response));
          } catch (e) {
            emit(Error(error: e.toString()));
          }
        }
      }
    });
  }
}

class ProductBlocModify extends Bloc<ProductsEvent, ProductsState> {
  final UpdateProductByIdUseCase updateProductUseCase;
  final DeleteProductByIdUseCase deleteProductUseCase;
  final GetProductsUseCase getPostsUseCase;
  final CreateProductUseCase createProductUseCase;
  final ProductRemoteDataSource remoteDataSource;

  ProductBlocModify(
      {required this.updateProductUseCase,
      required this.deleteProductUseCase,
      required this.getPostsUseCase,
      required this.createProductUseCase,
      required this.remoteDataSource})
      : super(Updating()) {
    on<ProductsEvent>((event, emit) async {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (event is UpdateProduct) {
        try {
          emit(Updating());
          await updateProductUseCase.execute(event.product);
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      }
      if (event is CreateProduct) {
        try {
          emit(Updating());
          await createProductUseCase.execute(event.product);
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      }
      if (event is DeleteProduct) {
        try {
          await deleteProductUseCase.execute(event.product);
          List<Product> products = await getPostsUseCase.execute();
          emit(Updated(products: products));
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      }
    });
  }
}
