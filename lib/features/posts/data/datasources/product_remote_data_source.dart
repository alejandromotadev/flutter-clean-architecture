import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:clean_architecture_bloc/features/posts/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  // https://jsonplaceholder.typicode.com/posts
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(
      String name, String description, double price);
}

class ProductRemoteDataSourceImp implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts() async {
    var response =
        await http.get(Uri.parse('http://192.168.29.154:1709/products/getall/'));
    if (response.statusCode == 200) {
      return convert
          .jsonDecode(response.body)
          .map<ProductModel>((data) => ProductModel.fromJson(data))
          .toList();
    } else {
      throw Exception();
    }
  }

  @override
  Future<ProductModel> createProduct(
      String name, String description, double price) async {
    final response = await http.post(
      Uri.parse("http://172.17.15.123:1709/products/getall/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
      }),
    );
    if (response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product.');
    }
  }
}
