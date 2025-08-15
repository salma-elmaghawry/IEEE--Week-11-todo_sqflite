// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/data/models/todo_model.dart';
import 'package:todo/logic/cubit/todo_cubit.dart';
import 'package:todo/presentation/screens/add_todo_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTodoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoError) {
            return Center(child: Text(state.message));
          } else if (state is TodoLoaded) {
            final incompleteTodos = state.todos.where((todo) => !todo.isCompleted).toList();
            final completeTodos = state.todos.where((todo) => todo.isCompleted).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodoSection(context, 'Incomplete', incompleteTodos),
                  _buildTodoSection(context, 'Completed', completeTodos),
                ],
              ),
            );
          }
          return const Center(child: Text('No todos yet'));
        },
      ),
    );
  }

  Widget _buildTodoSection(BuildContext context, String title, List<Todo> todos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Dismissible(
              key: Key(todo.id.toString()),
              background: Container(color: Colors.red),
              onDismissed: (direction) {
                context.read<TodoCubit>().deleteTodo(todo.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${todo.title} dismissed')),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(todo.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(todo.category),
                      Text(
                        '${todo.date.day}/${todo.date.month}/${todo.date.year}',
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      context.read<TodoCubit>().toggleTodoCompletion(todo);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}