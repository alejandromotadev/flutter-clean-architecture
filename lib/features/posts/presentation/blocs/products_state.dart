part of 'products_bloc.dart';

@immutable
abstract class ProductsState {
}

class Loading extends ProductsState {}

class Loaded extends ProductsState {
  final List<Product> products;
  Loaded({required this.products});
}

class LoadedOffline extends ProductsState {
  final List<Product> productsOffline;
  LoadedOffline({required this.productsOffline});
}

class Updating extends ProductsState{}

class Updated extends ProductsState{
  final List<Product> products;
  Updated({required this.products});
}

class Wifi extends ProductsState{}

class Error extends ProductsState {
  final String error;
  Error({required this.error});
}
