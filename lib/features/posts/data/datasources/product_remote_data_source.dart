import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:async';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:http/http.dart' as http;
import 'package:clean_architecture_bloc/features/posts/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductRemoteDataSource {
  // https://jsonplaceholder.typicode.com/posts
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(int id);
  Future<void> createProduct(Product product);
  Future<void> deleteProductById(Product product);
  Future<void> updateProductById(Product product);
}

class ProductRemoteDataSourceImp implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts() async {
    var response =
        await http.get(Uri.parse('http://172.17.1.86:1709/products/getall/'));
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
  Future<ProductModel> getProductById(int id) async {
    var response = await http
        .get(Uri.parse('hhttp://172.17.1.86:1709/products/getbyid/:id'));
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
      var url = Uri.http('172.17.1.86:1709', '/products/updateProduct/');
      var body = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      var headers = {'Content-Type': 'application/json'};
      await http.post(url, body: convert.jsonEncode(body), headers: headers);
  }

  @override
  Future<void> deleteProductById(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    print('This is delete ${product.id}');
    if (prefs.containsKey('updateProductOffline')) {
      String? encodedDataCache = prefs.getString('updateProductOffline');
      prefs.remove('updateNoteOffline');
      if (encodedDataCache != null) {
        List<dynamic> decodedList = json.decode(encodedDataCache);
        List<Product> products =
            decodedList.map((map) => Product.fromMap(map)).toList();

        List<Map<String, Object>> body = [];
        for (var updateProducts in products) {
          var object = {
            'id': updateProducts.id,
            'data': {
              'name': updateProducts.name,
              'description': updateProducts.description,
              'price': updateProducts.price
            }
          };
          body.add(object);
        }
        var url = Uri.https('http://172.17.1.86:1709/products/deleteProduct/');
        var headers = {'Content-Type': 'application/json'};
        await http.patch(url, body: convert.jsonEncode(body), headers: headers);
      }
    } else {
      var url =
          Uri.http('172.17.1.86:1709', '/products/deleteProduct/${product.id}');
      await http.delete(url);
    }
  }

  @override
  Future<void> updateProductById(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('deleteProductOffline')) {
      String? encodedPkCache = prefs.getString('deleteProductOffline');
      prefs.remove('deleteProductOffline');
      if (encodedPkCache != null) {
        List<dynamic> decodedList = json.decode(encodedPkCache);
        List<Product> notes =
            decodedList.map((map) => Product.fromMap(map)).toList();

        List<int> pks = [];
        for (var deletePk in notes) {
          pks.add(deletePk.id);
        }
        var object = {'primary_keys': pks};
        var url = Uri.https('http://172.17.1.86:1709/products/updateProduct/');
        var headers = {'Content-Type': 'application/json'};
        await http.post(url,
            body: convert.jsonEncode(object), headers: headers);
      }
    } else {
      var url = Uri.http('172.17.1.86:1709', '/products/updateProduct/');
      var body = {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
      };
      var headers = {'Content-Type': 'application/json'};
      await http.post(url, body: convert.jsonEncode(body), headers: headers);
    }
    // print('Deleted');
  }
}
