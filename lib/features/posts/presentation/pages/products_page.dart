import 'dart:async';
import 'package:clean_architecture_bloc/features/posts/domain/entities/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  late StreamSubscription<ConnectivityResult> subscription;
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(GetPosts());
  }

  void checkInternetConnection() async {
    // Verify internet connection on first open
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final prefs = await SharedPreferences.getInstance();
      // Check if notes were deleted offline
      if (prefs.containsKey('deleteProductsOffline')) {
        // print('Products deleted offline');
        String? encodedPksCache = prefs.getString('deleteProductOffline');
        if (encodedPksCache != null) {
          final BuildContext currentContext = context;
          Future.microtask((() {
            final productBloc = currentContext.read<ProductBlocModify>();
            productBloc.add(DeleteProduct(
                product: Product(
                    id: 0,
                    name: 'deleted',
                    description: 'deleted',
                    price: 0.0)));
          }));
        }
      }
      // Check if Products were edited offline
      if (prefs.containsKey('updateProductOffline')) {
        // print('products edited offline');
        String? encodedNotesEditedCache =
            prefs.getString('updateProductsOffline');
        if (encodedNotesEditedCache != null) {
          final BuildContext currentContext = context;
          Future.microtask((() {
            final productsBloc = currentContext.read<ProductBlocModify>();
            productsBloc.add(UpdateProduct(
                product: Product(
                    id: 0, name: 'edited', description: 'edited', price: 0.0)));
          }));
        }
      }
    } else {
      final BuildContext currentContext = context;
      Future.microtask(() {
        final notesBloc = currentContext.read<ProductsBloc>();
        notesBloc.add(GetProductsOffline());
        const snackBar = SnackBar(
          content: Text('No internet connection'),
          duration: Duration(days: 365),
        );
        ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
      });
    }

    // Verify connectivity changes
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        final prefs = await SharedPreferences.getInstance();
        // Check if notes were added offline

        // Check if notes were deleted offline
        if (prefs.containsKey('deleteProductsOffline')) {
          // print('Notes deleted offline');
          String? encodedPksCache = prefs.getString('deleteNoteOffline');
          if (encodedPksCache != null) {
            final BuildContext currentContext = context;
            Future.microtask((() {
              final productBloc = currentContext.read<ProductBlocModify>();
              productBloc.add(DeleteProduct(
                  product: Product(
                      id: 0,
                      name: 'deleted',
                      description: 'deleted',
                      price: 0.0)));
            }));
          }
        }
        // Check if notes were edited offline
        if (prefs.containsKey('updateNoteOffline')) {
          // print('Notes edited offline');
          String? encodedNotesEditedCache =
              prefs.getString('updateNoteOffline');
          if (encodedNotesEditedCache != null) {
            final BuildContext currentContext = context;
            Future.microtask((() {
              final productBloc = currentContext.read<ProductBlocModify>();
              productBloc.add(UpdateProduct(
                  product: Product(
                      id: 0,
                      name: 'edited',
                      description: 'edited',
                      price: 0.0)));
            }));
          }
        }
        final BuildContext currentContext = context;
        Future.microtask((() async {
          final productBloc = currentContext.read<ProductsBloc>();
          // notesBloc.add(GetNotes());
          await Future.delayed(const Duration(milliseconds: 95))
              .then((value) => productBloc.add(GetPosts()))
              .then((value) =>
                  ScaffoldMessenger.of(currentContext).clearSnackBars());
          // ScaffoldMessenger.of(currentContext).clearSnackBars();
        }));
      } else {
        context.read<ProductsBloc>().add(GetProductsOffline());
        const snackBar = SnackBar(
          content: Text('No internet connection'),
          duration: Duration(days: 365),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
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
                  children: state.products.map((post) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => {updateProduct(context, post, state)},
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        color: Colors.black12,
                        child: ListTile(
                          leading: Text(post.id.toString()),
                          title: Text(post.name),
                          subtitle: Text(post.description),
                          trailing: Text(post.price.toString()),
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
                          .add(GetPosts()));
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

  Future<void> updateProduct(
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
                          .add(GetPosts()));
                  //BlocProvider.of<ProductsBloc>(context).add(GetPosts());
                  nameController.clear();
                  descriptionController.clear();
                  priceController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Edit"),
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
          ],
        );
      },
    );
  }
}
