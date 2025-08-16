import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/data/models/todo_model.dart';
import 'package:todo/logic/cubit/todo_cubit.dart';
import 'package:todo/presentation/screens/add_todo_dialog.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          // Debug the current state
          print('Current TodoState: $state');

          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoError) {
            return Center(child: Text(state.message));
          } else if (state is TodoLoaded) {
            final incompleteTodos =
                state.todos.where((todo) => !todo.isCompleted).toList();
            final completeTodos =
                state.todos.where((todo) => todo.isCompleted).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // Header with date
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Summary count
                  Text(
                    "${incompleteTodos.length} Incomplete, ${completeTodos.length} completed",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Incomplete section
                  _buildSectionHeader('Incomplete'),
                  const SizedBox(height: 8),
                  _buildTodoList(context, incompleteTodos),
                  const SizedBox(height: 24),

                  // Completed section
                  _buildSectionHeader('Completed'),
                  const SizedBox(height: 8),
                  _buildTodoList(context, completeTodos, isCompleted: true),
                ],
              ),
            );
          }
          return const Center(child: Text('No todos yet'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use the existing TodoCubit from the parent instead of creating a new one
        return AddTodoDialog();
      },
    ).then((_) {
      // Refresh todos after dialog is closed
      context.read<TodoCubit>().loadTodos();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTodoList(
    BuildContext context,
    List<Todo> todos, {
    bool isCompleted = false,
  }) {
    return Column(
      children:
          todos.map((todo) {
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
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    todo.category,
                    style: TextStyle(color: Colors.grey[600]),
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
          }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
