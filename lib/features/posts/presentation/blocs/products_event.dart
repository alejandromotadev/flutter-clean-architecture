part of 'products_bloc.dart';

@immutable
abstract class ProductsEvent {}

class GetPosts extends ProductsEvent {}

class Connections extends ProductsEvent{}