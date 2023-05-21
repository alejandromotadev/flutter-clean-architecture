import 'dart:convert' as convert;
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:http/http.dart' as http;

import 'package:clean_architecture_bloc/features/posts/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  // https://jsonplaceholder.typicode.com/posts
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> updateProducts();
  Future<List<ProductModel>> deleteProducts();
  Future<List<ProductModel>> createProducts();
}

class ProductRemoteDataSourceImp implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts() async {
    //print('DataSource');
    var url = Uri.https('jsonplaceholder.typicode.com', '/posts');
    var response = await http.get(url);
    if(response.statusCode == 200) {
      return convert.jsonDecode(response.body)
              .map<ProductModel>((data) => ProductModel.fromJson(data))
              .toList();
    } else {
      throw Exception();
    }
  }
  Future<List<ProductModel>> createProducts() async {
    //print('DataSource');
    var url = Uri.https('jsonplaceholder.typicode.com', '/posts');
    var response = await http.get(url);
    if(response.statusCode == 200) {
      return convert.jsonDecode(response.body)
          .map<ProductModel>((data) => ProductModel.fromJson(data))
          .toList();
    } else {
      throw Exception();
    }
  }
  Future<List<ProductModel>> updateProducts() async {
    //print('DataSource');
    var url = Uri.https('jsonplaceholder.typicode.com', '/posts');
    var response = await http.get(url);
    if(response.statusCode == 200) {
      return convert.jsonDecode(response.body)
          .map<ProductModel>((data) => ProductModel.fromJson(data))
          .toList();
    } else {
      throw Exception();
    }
  }
  Future<List<ProductModel>> deleteProducts() async {
    //print('DataSource');
    var url = Uri.https('jsonplaceholder.typicode.com', '/del');
    var response = await http.get(url);
    if(response.statusCode == 200) {
      return convert.jsonDecode(response.body)
          .map<ProductModel>((data) => ProductModel.fromJson(data))
          .toList();
    } else {
      throw Exception();
    }
  }
}