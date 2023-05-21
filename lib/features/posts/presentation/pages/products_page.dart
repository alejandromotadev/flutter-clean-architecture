import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clean_architecture_bloc/features/posts/presentation/blocs/products_bloc.dart';

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
                  return Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    color: Colors.black12,

                    child: ListTile(
                      leading: Text(post.id.toString()),
                      title: Text(post.name),
                      subtitle: Text(post.description),
                    ),
                  );
                }).toList()
              ),
            );
          } else if(state is Error) {
            return Center(
              child: Text(state.error, style: const TextStyle(color: Colors.red)),
            );
          } else {
            return Container();
          }
        }
      ),
    );
  }
}
