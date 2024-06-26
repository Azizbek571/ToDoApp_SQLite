import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../services/todo_service.dart';
import '../services/user_service.dart';
import 'package:sqlite_provider_starter/models/todo.dart';

import '../widgets/dialogs.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late TextEditingController todoController;

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Create a new TODO'),
                              content: TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Please enter TODO'),
                                controller: todoController,
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Save'),
                                  onPressed: () async {
                                    if (todoController.text.isEmpty) {
                                      showSnackBar(context,
                                          'Please enter a todo first, then save');
                                    } else {
                                      String username = await context
                                          .read<UserService>()
                                          .currentUser
                                          .username;
                                          Todo todo = Todo(username: username, 
                                          title: todoController.text.trim(), 
                                          created: DateTime.now());
                                          if (context.read<TodoService>().todos.contains(todo))
                                          {
                                            showSnackBar(context, 'Duplicate value, Please try again');
                                          }
                                          else{
                                            String result = await context.read<TodoService>().createTodo(todo);
                                            if (result == 'OK'){
                                              showSnackBar(context, 'New todo successfully added');
                                              todoController.text = '';
                                            } else {
                                              showSnackBar(context, result);
                                            }
                                            Navigator.pop(context);
                                          }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Selector<UserService, User>(
                  selector: (context, value) => value.currentUser,
                  builder: (context, value, child) {
                    return Text(
                      "${value.name}\'s Todo list",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              // Expanded(
              //   child: Padding(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
              //     child: Consumer(
              //       builder: (context, value, child) {
              //         return ListView.builder(
              //           // itemCount: value?.todos.length,
              //           itemBuilder: (context, index) {
              //             return TodoCard(
              //               todo: value?.todos[index],
              //             );
              //           },
              //         );
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  const TodoCard({
    Key? key,
    required this.todo,
  }) : super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade300,
      // child: Slidable(
        // endActionPane: SlidableDrawerActionPane(),

        // secondaryActions: [
        //   IconSlideAction(
          //   caption: 'Delete',
          //   color: Colors.purple[600],
          //   icon: Icons.delete,
          //   onTap: () async {
          //     String result = await context.read<TodoService>().deleteTodo(todo);
          //     if (result == 'OK'){
          //       showSnackBar(context, 'Successfully deleted');
          //     } else {
          //       showSnackBar(context, result);
          //     }
          //   },
          // ),
        // ],
        child: CheckboxListTile(
          checkColor: Colors.purple,
          activeColor: Colors.purple[100],
          value: todo.done,
          onChanged: (value) async {
            String result = await context.read<TodoService>().toggleTodoDone(todo);
            if (result != 'OK'){
              showSnackBar(context, result);
            }
          },
          subtitle: Text(
            '${todo.created.day}/${todo.created.month}/${todo.created.year}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          title: Text(
            todo.title,
            style: const TextStyle(
              color: Colors.white,
              // decoration: todo.done ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ),
      // ),
    );
  }
}
