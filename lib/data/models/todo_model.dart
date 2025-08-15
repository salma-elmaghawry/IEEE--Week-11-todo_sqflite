class Todo {
  final int? id;
  final String title;
  final String? description;
  final String category;
  final DateTime date;
  final bool isCompleted;

  Todo({
    this.id,
    required this.title,
    this.description,
    required this.category,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}