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

const String baseUrl = "44.216.76.26";

class ProductRemoteDataSourceImp implements ProductRemoteDataSource {

  @override
  Future<List<ProductModel>> getProducts() async {
    if (await isOnline()) {
      print("is online");
      final response = await http.get(Uri.http(baseUrl, '/products/getall/'));
      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = convert.jsonDecode(response.body);
          final List<ProductModel> products = responseData
              .map<ProductModel>((data) => ProductModel.fromJson(data))
              .toList();
          await PreferencesHelper.saveProducts(products);
          // Check if there are any pending products and send them
          final pendingProducts = await PreferencesHelper.getPendingProducts();
          if (pendingProducts.isNotEmpty) {
            print("if pending");
            print(pendingProducts[0]);
            await PreferencesHelper._sendPendingProducts();
          }
          return products;
        } catch (e) {
          return [];
        }
      } else {
        throw Exception('Error al obtener los productos');
      }
    } else {
      print("NO ONLINE");
      final products = await PreferencesHelper.getProducts();
      return products
          .map((product) => ProductModel.fromJson(product.toJson()))
          .toList();
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
    if (await isOnline()) {
      final url = Uri.http(baseUrl, '/products/createProduct/');
      final body = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      final headers = {'Content-Type': 'application/json'};
      try {
        print("post");
        final response=await http.post(url, body: convert.jsonEncode(body), headers: headers);
        print(response.body);
      } catch (e) {
        print('Error al crear el producto: $e');
        await PreferencesHelper.addPendingProduct(product);
      }
    } else {
      await PreferencesHelper.addPendingProduct(product);
    }
  }

  @override
  Future<void> deleteProductById(Product product) async {
    if (await isOnline()){
      final url = Uri.http(baseUrl, '/products/deleteProduct/${product.id}');
      try {
        await http.delete(url);
      } catch (e) {
        await PreferencesHelper.addPendingProduct(product);
      }
    } else {
      await PreferencesHelper.addPendingProduct(product);
    }

  }

  @override
  Future<void> updateProductById(Product product) async {
    if (await isOnline()){
      var url = Uri.http(baseUrl, '/products/updateProduct/');
      var body = {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      var headers = {'Content-Type': 'application/json'};
      try {
        await http.post(url, body: convert.jsonEncode(body), headers: headers);

      } catch (e){
        await PreferencesHelper.addPendingProduct(product);

      }
    } else {
      await PreferencesHelper.addPendingProduct(product);
    }

  }

  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

}

class PreferencesHelper {
  static const String productsKey = 'products';
  static const String pendingProductsKey = 'pendingProducts';

  static Future<SharedPreferences> _getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  static Future<List<ProductModel>> getProducts() async {
    final prefs = await _getSharedPreferencesInstance();
    final productsJson = prefs.getStringList(productsKey);
    if (productsJson != null) {
      return productsJson
          .map((json) => ProductModel.fromJson(jsonDecode(json)))
          .toList();
    }
    return [];
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await _getSharedPreferencesInstance();
    final productsJson =
        products.map((product) => jsonEncode(product.toJson())).toList();
    await prefs.setStringList(productsKey, productsJson);
  }

  static Future<void> clearProducts() async {
    final prefs = await _getSharedPreferencesInstance();
    await prefs.remove(productsKey);
  }

  static Future<List<Product>> getPendingProducts() async {
    final prefs = await _getSharedPreferencesInstance();
    final pendingProductsJson = prefs.getStringList(pendingProductsKey);
    if (pendingProductsJson != null) {
      print("=================");
      print(pendingProductsJson);
      return pendingProductsJson
          .map((json) => ProductModel.fromJson(jsonDecode(json)))
          .toList();
    }
    return [];
  }

  static Future<void> addPendingProduct(Product product) async {
    final prefs = await _getSharedPreferencesInstance();
    final List<String> pendingProducts = prefs.getStringList(pendingProductsKey) ?? [];
    pendingProducts.add(json.encode(product.toJson()));
    print(pendingProducts);
    await prefs.setStringList(pendingProductsKey, pendingProducts);
  }

  static Future<void> _sendPendingProducts() async {
    final prefs = await PreferencesHelper._getSharedPreferencesInstance();
    final List<String> pendingProductsJson =
        prefs.getStringList(pendingProductsKey) ?? [];
    for (final productJson in pendingProductsJson) {
      final product = ProductModel.fromJson(convert.jsonDecode(productJson));
      final url = Uri.http(baseUrl, 'products/createProduct/');
      final body = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      final headers = {'Content-Type': 'application/json'};

      try {
        await http.post(url, body: convert.jsonEncode(body), headers: headers);
        prefs.remove(pendingProductsKey);
        pendingProductsJson.remove(productJson);
      } catch (e) {
        print('Error al enviar producto pendiente: $e');
      }
    }
    await prefs.setStringList(PreferencesHelper.pendingProductsKey, pendingProductsJson);
  }

  /*static Future<void> savePendingProducts(List<Product> pendingProducts) async {
    final prefs = await _getSharedPreferencesInstance();
    final pendingProductsJson =
        pendingProducts.map((product) => jsonEncode(product.toJson())).toList();
    await prefs.setStringList(pendingProductsKey, pendingProductsJson);
  }*/

  static Future<void> clearPendingProducts() async {
    final prefs = await _getSharedPreferencesInstance();
    await prefs.remove(pendingProductsKey);
  }

  static List<Map<String, dynamic>> productListToJson(List<Product> products) {
    return products.map((product) => product.toJson()).toList();
  }
}
