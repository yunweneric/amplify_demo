import 'dart:math';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:my_amplify_app/models/Todo.dart';

showTodoAddModal({required BuildContext context, required Function onPop}) {
  TextEditingController controller = TextEditingController();
  return showDialog(
    context: context,
    builder: (c) {
      return AlertDialog(
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: Column(
            children: [
              Text(
                "Add todo",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  final newTodo = Todo(
                    content: controller.text.trim(),
                    id: Random().nextInt(200).toString(),
                    isDone: false,
                  );
                  final request = ModelMutations.create(newTodo);
                  final response = await Amplify.API.mutate(request: request).response;
                  if (response.hasErrors) {
                    safePrint('Creating Todo failed.');
                    safePrint(response.errors);
                  } else {
                    safePrint('Creating Todo successful.');
                    Navigator.pop(context);
                    onPop.call();
                  }
                },
                child: const Text("Add todo"),
              )
            ],
          ),
        ),
      );
    },
  );
}
