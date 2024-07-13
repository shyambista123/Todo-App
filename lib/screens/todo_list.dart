import 'dart:convert';

import 'package:crud_app/screens/add_edit_todo.dart';
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
        backgroundColor: Colors.deepPurple,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodos,
          child: todos.isEmpty
          ? Center(child: Text("No items"))
          : ListView.builder(
            itemCount: todos.length ,
            itemBuilder: (context, index){
              final todo = todos[index] as Map;
              final id = todo['id'] as String;
            return ListTile(
              leading: CircleAvatar(child: Text("${index+1}"),),
              title: Text(todo['title']),
              subtitle: Text(todo['description']),
              trailing: PopupMenuButton(
                onSelected: (value){
                  if(value=='edit'){
                    //open edit page 
                    navigateToEditPage(todo);
                  }
                  else if(value=='delete'){
                    //delete and refresh the page / remove th todo 
                    deleteById(id);
                  }
                },
                itemBuilder: (context){
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child:  Text("Edit")
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child:  Text("Delete"),
                    )
                ];
              },),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: navigateToAddPage, label: const Text("Add todo")),
    );
  }
  Future<void> navigateToAddPage()async{
    final route = MaterialPageRoute(builder: (context)=>AddTodoPage());
    await  Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodos(); 
  }

  Future<void> navigateToEditPage(Map todo)async{
    final route = MaterialPageRoute(builder: (context)=>AddTodoPage(todo: todo));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodos(); 
  }

  Future<void> deleteById(String id) async{
    //delete the item 
    final url = "http://192.168.1.64:8080/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri); 
    if(response.statusCode==200){
    //remove from the list 
    final filtered = todos.where((element) =>element['id']!=id).toList();
    setState(() {
      todos = filtered;
    });
    }
    else{
      //show error message
      showErrorMessage("Error while deleting todo");
    }
  }

  Future<void> fetchTodos() async{
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

  void showErrorMessage(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}