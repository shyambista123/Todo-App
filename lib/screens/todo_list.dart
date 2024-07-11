import 'dart:convert';

import 'package:crud_app/screens/add_todo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {

  bool isLoading = true;

  List todos = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodos(); 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 233, 31, 31),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodos,
          child: ListView.builder(
            itemCount: todos.length ,
            itemBuilder: (context, index){
              final todo = todos[index] as Map;
            return ListTile(
              title: Text(todo['title']),
              subtitle: Text(todo['description']),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: navigateToAddPage, label: const Text("Add todo")),
    );
  }
  void navigateToAddPage(){
    final route = MaterialPageRoute(builder: (context)=>AddTodoPage());
    Navigator.push(context, route);
  }

  Future<void> fetchTodos() async{
    setState(() {
      isLoading = false;
    }); 
    final url = "http://192.168.1.64:8080/todos";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode == 200){
      final json = jsonDecode(response.body) as List;
      setState(() {
        todos = json;
      });
    }
    else{
      print("Error");
    }
    setState(() {
      isLoading = false;
    });
  }
}