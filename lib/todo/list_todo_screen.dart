import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:my_amplify_app/models/Todo.dart';
import 'package:my_amplify_app/todo/show_add_modal.dart';

class ListTodoScreen extends StatefulWidget {
  const ListTodoScreen({super.key});

  @override
  State<ListTodoScreen> createState() => _ListTodoScreenState();
}

class _ListTodoScreenState extends State<ListTodoScreen> {
  List<Todo> _todos = [];
  Future<void> _refreshTodos() async {
    try {
      // final request = ModelQueries.list(Todo.classType, authorizationMode: APIAuthorizationType.iam);

      final request = ModelQueries.list(Todo.classType);
      final response = await Amplify.API.query(request: request).response;

      final todos = response.data?.items;
      if (response.hasErrors) {
        safePrint('errors: ${response.errors}');
        return;
      }
      setState(() {
        safePrint('todos: ${response}');
        safePrint(todos);
        _todos = todos!.whereType<Todo>().toList();
      });
    } on ApiException catch (e) {
      safePrint('Query failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTodoAddModal(
          context: context,
          onPop: () {
            _refreshTodos();
          },
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _todos.isEmpty
                    ? SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: Center(child: Text("No todos")),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _todos.length,
                        separatorBuilder: (c, i) => SizedBox(height: 10),
                        itemBuilder: (c, i) {
                          return TodoCard(
                            todo: _todos[i],
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  final Todo todo;
  const TodoCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(todo.content));
  }
}
