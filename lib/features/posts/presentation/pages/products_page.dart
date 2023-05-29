import 'dart:async';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_bloc/features/posts/presentation/blocs/products_bloc.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late StreamSubscription<ConnectivityResult> subscription;
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(InitialState());
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      floatingActionButton: ElevatedButton(
          child: const Text("Create Product"),
          onPressed: () async {
            addProduct(context);
          }),
      body: BlocBuilder<ProductsBloc, ProductsState>(builder: (context, state) {
        if (state is Loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is Loaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  children: state.products.map((product) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => {selectedProduct(context, product, state)},
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        color: Colors.black12,
                        child: ListTile(
                          leading: Text(product.id.toString()),
                          title: Text(product.name),
                          subtitle: Text(product.description),
                          trailing: Text(product.price.toString()),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList()),
            ),
          );
        } else if (state is LoadedOffline) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  children: state.productsOffline.map((productOffline) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => {selectedProduct(context, productOffline, state)},
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        color: Colors.black12,
                        child: ListTile(
                          leading: Text(productOffline.id.toString()),
                          title: Text(productOffline.name),
                          subtitle: Text(productOffline.description),
                          trailing: Text(productOffline.price.toString()),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList()),
            ),
          );
        } else if (state is Error) {
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
      }),
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
          title: const Text("Add your product"),
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
                    descriptionController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  const snackBar = SnackBar(
                    content:
                        Text('Hey you should type something! Try again ;)'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  final productAux = Product(
                      id: 0,
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.parse(priceController.text));
                  BlocProvider.of<ProductBlocModify>(context)
                      .add(CreateProduct(product: productAux));
                  await Future.delayed(const Duration(milliseconds: 95)).then(
                      (value) => BlocProvider.of<ProductsBloc>(context)
                          .add(InitialState()));
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

  Future<void> selectedProduct(
      BuildContext context, Product product, ProductsState state) async {
    final nameController = TextEditingController(text: product.name);
    final descriptionController =
        TextEditingController(text: product.description);
    final priceController =
        TextEditingController(text: product.price.toString());
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.id.toString(),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "name",
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "description",
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "price",
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
                BlocProvider.of<ProductBlocModify>(context)
                    .add(DeleteProduct(product: product));

                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  const snackBar = SnackBar(
                    content:
                        Text('Hey you should type something! Try again ;)'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  final productAux = Product(
                      id: product.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.parse(priceController.text));
                  BlocProvider.of<ProductBlocModify>(context)
                      .add(UpdateProduct(product: productAux));
                  await Future.delayed(const Duration(milliseconds: 95)).then(
                      (value) => BlocProvider.of<ProductsBloc>(context)
                          .add(InitialState()));
                  nameController.clear();
                  descriptionController.clear();
                  priceController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
