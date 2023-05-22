import 'dart:ui';
import 'package:clean_architecture_bloc/features/posts/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_bloc/features/posts/presentation/pages/products_page.dart';
import 'package:clean_architecture_bloc/usecase_config.dart';
import 'package:clean_architecture_bloc/features/posts/presentation/blocs/products_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          create: (BuildContext context) => ProductsBloc(getPostsUseCase: usecaseConfig.getPostsUsecase!)
        ),

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:  LoadPage(),
      ),
    );
  }
}
class LoadPage extends StatefulWidget {
  LoadPage({Key? key}) : super(key: key);

  @override
  LoadPageState createState() => LoadPageState();
}

class LoadPageState extends State {
  late bool newLaunch = false;

  @override
  void initState() {
    super.initState();
    loadNewLaunch();
  }

  loadNewLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bool _newLaunch = ((prefs.getBool('newLaunch') ?? true));
      newLaunch = _newLaunch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: newLaunch ? SplashScreen() : const ProductsPage());
  }
}
