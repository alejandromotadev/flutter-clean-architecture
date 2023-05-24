part of 'products_bloc.dart';

@immutable
abstract class ProductsEvent {}

class GetPosts extends ProductsEvent {}

class Connections extends ProductsEvent{}

class UpdateProduct extends ProductsEvent{
  final Product product;
  UpdateProduct({required this.product});

}

class CreateProduct extends ProductsEvent{
  final Product product;
  CreateProduct({required this.product});
}

class DeleteProduct extends ProductsEvent{
  final Product product;
  DeleteProduct({required this.product});

}
class GetProductsOffline extends ProductsEvent{}

