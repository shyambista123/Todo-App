import 'dart:convert';
import 'package:crud_app/screens/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTodoPage extends StatefulWidget {
  const EditTodoPage({super.key});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Todo", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(padding: EdgeInsets.all(20), children: [
        TextField(
          decoration: InputDecoration(hintText: "Title"),
          controller: titleController,
        ),
        TextField(
            decoration: InputDecoration(hintText: "Description"),
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8),
        ElevatedButton(onPressed: submitData, child: Text("Save"))
      ]),
    );
  }

  Future<void> submitData() async {
    // Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    // submit that data to the server
    final url = "http://192.168.1.64:8080/todos";
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Creation Success');

      // naviagte to the todo list page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TodoListPage(), // Replace TodoListPage with your actual list page
        ),
      );

    } else {
      showErrorMessage("Creation Error");
    }
  }
  // show the success or fail message based on status

  void showSuccessMessage(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
