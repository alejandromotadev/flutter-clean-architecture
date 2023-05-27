import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:async';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:clean_architecture_bloc/features/posts/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(int id);
  Future<void> createProduct(Product product);
  Future<void> deleteProductById(Product product);
  Future<void> updateProductById(Product product);
  Future<bool> checkInternetConnection();
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> removeCachedProduct(int id);
  Future<void> cacheProductForCreation(Product product);
  Future<void> cacheProductIdForDeletion(int id);
}


class ProductRemoteDataSourceImp implements ProductRemoteDataSource {
  final String baseUrl = "192.168.1.103:1709"; //baseUrl
  final cacheKey = 'product_cache'; // Clave para la cache
  final SharedPreferences sharedPreferences;
  ProductRemoteDataSourceImp({required this.sharedPreferences});


  @override
  Future<List<ProductModel>> getProducts() async {
    final hasConnection = await checkInternetConnection();
    if (hasConnection) {
      final response =
      await http.get(Uri.http(baseUrl, '/products/getall/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final products = jsonData
            .map((productJson) => ProductModel.fromJson(productJson))
            .toList();

        await cacheProducts(products);

        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } else {
      return getCachedProducts();
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final hasConnection = await checkInternetConnection();

    if (hasConnection) {
      final response =
      await http.get(Uri.http(baseUrl, '/products/getbyid/$id'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load product');
      }
    } else {
      final cachedProducts = await getCachedProducts();
      final product = cachedProducts.firstWhere((p) => p.id == id);
      return product;
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    final hasConnection = await checkInternetConnection();

    if (hasConnection) {
      final response = await http.post(
        Uri.http(baseUrl, '/products/createProduct/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ProductModel.fromEntity(product).toJson()),
      );
      response;
      if (response.statusCode != 200) {
        throw Exception('Failed to create product');
      }
    } else {
      await cacheProductForCreation(product);
    }
  }

  @override
  Future<void> deleteProductById(Product product) async {
    final hasConnection = await checkInternetConnection();

    if (hasConnection) {
      final response = await http.delete(Uri.http(baseUrl, '/products/deleteProduct/${product.id}'));

      if (response.statusCode == 200) {
        await removeCachedProduct(product.id);
      } else {
        throw Exception('Failed to delete product');
      }
    } else {
      await cacheProductIdForDeletion(product.id);
    }
  }

  @override
  Future<void> updateProductById(Product product) async {
    final hasConnection = await checkInternetConnection();

    if(hasConnection){
      final response = await http.post(
        Uri.http(baseUrl, '/products/updateProduct/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ProductModel.fromEntity(product).toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create product');
      }
    }else {
      await cacheProductForCreation(product);
    }
  }

  @override
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final jsonString = sharedPreferences.getString(cacheKey);

    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((jsonProduct) => ProductModel.fromJson(jsonProduct))
          .toList();
    }

    return [];
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final jsonList = products.map((product) => product.toJson()).toList();
    await sharedPreferences.setString(cacheKey, json.encode(jsonList));
  }

  @override
  Future<void> removeCachedProduct(int id) async {
    final cachedProducts = await getCachedProducts();
    final updatedProducts =
    cachedProducts.where((product) => product.id != id).toList();
    await cacheProducts(updatedProducts);
  }

  @override
  Future<void> cacheProductForCreation(Product product) async {
    final cachedProducts = await getCachedProducts();
    cachedProducts.add(ProductModel.fromEntity(product));
    await cacheProducts(cachedProducts);
  }

  @override
  Future<void> cacheProductIdForDeletion(int id) async {
    final cachedProducts = await getCachedProducts();
    final updatedProducts =
    cachedProducts.where((product) => product.id != id).toList();
    await cacheProducts(updatedProducts);
  }



  
}

