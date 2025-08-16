import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo/data/database_helper.dart';
import 'package:todo/data/models/todo_model.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final DatabaseHelper dbHelper;

  TodoCubit(this.dbHelper) : super(TodoInitial()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    emit(TodoLoading());
    try {
      final todos = await dbHelper.readAllTodos();
      print('Loaded ${todos.length} todos from database');
      emit(TodoLoaded(todos));
    } catch (e) {
      print('Error loading todos: $e');
      emit(TodoError(e.toString()));
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      emit(TodoLoading()); // Emit loading state to trigger UI refresh
      await dbHelper.createTodo(todo);
      final todos = await dbHelper.readAllTodos();
      emit(TodoLoaded(todos)); // Emit new state with updated todos
    } catch (e) {
      emit(TodoError('Failed to add todo: ${e.toString()}'));
    }
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    if (state is TodoLoaded) {
      try {
        final updatedTodo = Todo(
          id: todo.id,
          title: todo.title,
          category: todo.category,
          date: todo.date,
          isCompleted: !todo.isCompleted,
        );
        await dbHelper.updateTodo(updatedTodo);
        final todos = await dbHelper.readAllTodos();
        emit(TodoLoaded(todos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> deleteTodo(int id) async {
    if (state is TodoLoaded) {
      try {
        await dbHelper.deleteTodo(id);
        final todos = await dbHelper.readAllTodos();
        emit(TodoLoaded(todos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> fetchTodos() async {
    try {
      final todos = await dbHelper.readAllTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }
}
