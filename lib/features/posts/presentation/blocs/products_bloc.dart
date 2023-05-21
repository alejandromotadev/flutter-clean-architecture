import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:clean_architecture_bloc/features/posts/domain/usecases/get_products_usecase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getPostsUseCase;

  ProductsBloc({required this.getPostsUseCase}) : super(Loading()) {
    on<ProductsEvent>((event, emit) async {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi) {
        if (event is GetPosts) {
          try {
            List<Product> response = await getPostsUseCase.execute();
            emit(Loaded(products: response));
          } catch (e) {
            print(e.toString());
            emit(Error(error: e.toString()));
          }
        }
      } else {
        print("error");
        emit(Error(error: "Connection failed"));
      }
    });
  }
}
