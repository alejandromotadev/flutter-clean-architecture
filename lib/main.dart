import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_bloc/features/posts/presentation/pages/products_page.dart';
import 'package:clean_architecture_bloc/usecase_config.dart';
import 'package:clean_architecture_bloc/features/posts/presentation/blocs/products_bloc.dart';

UsecaseConfig usecaseConfig = UsecaseConfig();


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsBloc>(
          create: (BuildContext context) => ProductsBloc(
            getPostsUseCase: usecaseConfig.getPostsUsecase!,
              remoteDataSource: usecaseConfig.postRemoteDataSourceImp!,
          )
        ),
        BlocProvider<ProductBlocModify>(
          create: (BuildContext context) => ProductBlocModify(
            updateProductUseCase : usecaseConfig.updateProductByIdUseCase!,
            deleteProductUseCase: usecaseConfig.deleteProductUsecase!,
            getPostsUseCase: usecaseConfig.getPostsUsecase!,
            createProductUseCase: usecaseConfig.createProductUseCase!,
            remoteDataSource: usecaseConfig.postRemoteDataSourceImp!,
          )
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const ProductsPage(),
      ),
    );
  }
}

