import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clean_architecture_bloc/features/posts/presentation/blocs/products_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(GetPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      floatingActionButton:  ElevatedButton(
          child: Text("Create Product"),
          onPressed: () async {
            addProduct(context);
          }
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if(state is Loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if(state is Loaded) {
            return SingleChildScrollView(
              child: Column(
                children: state.products.map((post) {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(5),
                        color: Colors.black12,
                        child: ListTile(
                          leading: Text(post.id.toString()),
                          title: Text(post.name),
                          subtitle: Text(post.description),
                          trailing: Text(post.price.toString()),
                        ),
                      ),
                    ],
                  );
                }).toList()
              ),
            );
          } else if(state is Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error, style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          } else {
            return Container();
          }
        }
      ),
    );
  }
  Future<void> addProduct(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add your link"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "Price",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty || priceController.text.isEmpty) {
                  const snackBar = SnackBar(
                    content:
                    Text('Hey you should type something! Try again ;)'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  final Map<String, dynamic> newProduct = {
                    'name': nameController.text,
                    'name': descriptionController.text,
                    'price': priceController.text,
                  };
                  nameController.clear();
                  descriptionController.clear();
                  priceController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
