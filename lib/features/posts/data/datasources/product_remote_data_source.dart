import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:async';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:http/http.dart' as http;
import 'package:clean_architecture_bloc/features/posts/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(int id);
  Future<void> createProduct(Product product);
  Future<void> deleteProductById(Product product);
  Future<void> updateProductById(Product product);
}

const String baseUrl = "3.90.108.228";

class ProductRemoteDataSourceImp implements ProductRemoteDataSource {

  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }


  @override
  Future<List<ProductModel>> getProducts() async {
    if (await isOnline()) {
      final response = await http.get(Uri.http(baseUrl, '/products/getall/'));
      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = convert.jsonDecode(response.body);
          final List<ProductModel> products = responseData
              .map<ProductModel>((data) => ProductModel.fromJson(data))
              .toList();
          await PreferencesHelper.saveProducts(products);
          return products;
        } catch (e) {
          return [];
        }
      } else {
        throw Exception('Error al obtener los productos');
      }
    } else {
      return await PreferencesHelper.getProducts();
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
      var response = await http.get(Uri.http(baseUrl, '/products/getbyid/$id'));
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
  Future<void> createProduct(Product product) async {
      final url = Uri.http(baseUrl, '/products/createProduct/');
      final body = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      final headers = {'Content-Type': 'application/json'};
      try {
        await http.post(url, body: convert.jsonEncode(body), headers: headers);
      } catch (e) {
        throw Exception();
      }

  }

  @override
  Future<void> deleteProductById(Product product) async {
      final url = Uri.http(baseUrl, '/products/deleteProduct/${product.id}');
      try {
        await http.delete(url);
      } catch (e) {
        throw Exception();
      }

  }

  @override
  Future<void> updateProductById(Product product) async {
      var url = Uri.http(baseUrl, '/products/updateProduct/');
      var body = {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      var headers = {'Content-Type': 'application/json'};
      await http.post(url, body: convert.jsonEncode(body), headers: headers);

  }
}

class PreferencesHelper {
  static const String keyProducts = 'products';

  static Future<SharedPreferences> _getPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  static Future<List<ProductModel>> getProducts() async {
    final prefs = await _getPreferencesInstance();
    final productsJson = prefs.getStringList(keyProducts) ?? [];
    return productsJson.map<ProductModel>((productJson) => ProductModel.fromJson(convert.jsonDecode(productJson))).toList();
  }

  static Future<void> saveProducts(List<ProductModel> products) async {
    final prefs = await _getPreferencesInstance();
    final productsJson = products.map<String>((product) => convert.jsonEncode(product.toJson())).toList();
    await prefs.setStringList(keyProducts, productsJson);
  }
}
