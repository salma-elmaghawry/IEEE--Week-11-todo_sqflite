import 'package:flutter/material.dart';
import 'package:todo/data/database_helper.dart';
import 'package:todo/logic/cubit/todo_cubit.dart';
import 'package:todo/presentation/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper.instance;
  runApp( MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;
 const MyApp({Key? key, required this.dbHelper}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: BlocProvider(
        create: (context) => TodoCubit(dbHelper),
        child:  HomeScreen(),
      ),
    );
  }
}
