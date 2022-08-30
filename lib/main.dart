import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SharedPrefController {
  Future putData(todoList) async {
    var key = "";
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, TodoItem.encode(todoList));
  }

  Future<List<TodoItem>> getData() async {
    var key = "";
    final prefs = await SharedPreferences.getInstance();
    return TodoItem.decode(prefs.getString(key)!);
  }
}

class TodoItem {
  String title;
  String description;
  bool completed;

  TodoItem(
      {required this.title,
      required this.description,
      required this.completed});

  TodoItem.fromJSON(Map<String, dynamic> json)
      : title = json['title'],
        description = json["description"],
        completed = json['completed'];

  static Map<String, dynamic> toJSON(TodoItem item) => {
        'title': item.title,
        'description': item.description,
        'completed': item.completed
      };

  static String encode(List<TodoItem> items) => json.encode(
        items
            .map<Map<String, dynamic>>((item) => TodoItem.toJSON(item))
            .toList(),
      );

  static List<TodoItem> decode(String items) =>
      (json.decode(items) as List<dynamic>)
          .map<TodoItem>((item) => TodoItem.fromJSON(item))
          .toList();

  void complete() {
    // Mark the todoItem as completed
    // Call it in the actions of Slidable widget
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SharedPrefController controller = SharedPrefController();
  late List<TodoItem> list = [];

  //List<TodoItem> list = [TodoItem(title: "Do work", description: "bla bla bla"), TodoItem(title: "Another work", description: "another bla")];

  void getHomeData() async {
    var listNew = await controller.getData();
    setState(() {
      list = listNew;
    });
  }

  @override
  void initState() {
    super.initState();
    getHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0ECE2),
      appBar: AppBar(
        backgroundColor: const Color(0xff596E79),
        title: const Text("Todo List"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              key: const ValueKey(0),
              endActionPane: ActionPane(motion: const ScrollMotion(), children: [
                SlidableAction(
                    onPressed: (context) {
                      list[list.length - index - 1].completed = true;
                      setState(() {
                        controller.putData(list);
                      });
                    },
                    backgroundColor: const Color(0xffC7B198),
                    foregroundColor: Colors.white,
                    icon: Icons.check,
                    label: 'Completed'),
                SlidableAction(
                    onPressed: (context) {
                      list.removeAt(list.length - index - 1);
                      setState(() {
                        controller.putData(list);
                      });
                    },
                    backgroundColor: const Color(0xffDD4A48),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete')
              ]),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ItemPage(item: list[list.length - index - 1],)
                  ));
                },
                child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                        color: list[list.length - index - 1].completed
                            ? const Color(0xffC7B198)
                            : const Color(0xffDFD3C3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list[list.length - index - 1].title,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: list[list.length - index - 1].completed
                                  ? Colors.white
                                  : const Color(0xff596E79)),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          list[list.length - index - 1].description,
                          style: TextStyle(
                            fontSize: 12,
                            color: list[list.length - index - 1].completed
                                ? Colors.white
                                : const Color(0xff596E79),
                          ),
                        )
                      ],
                    )),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff596E79),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddItemScreen(itemList: list)),
          ).then((_) {
            getHomeData();
          });
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final List<TodoItem>? itemList;

  const AddItemScreen({Key? key, @required this.itemList}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  var title = "";
  var description = "";
  final SharedPrefController controller = new SharedPrefController();
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff596E79),
      appBar: AppBar(
        backgroundColor: const Color(0xffC7B198),
        title: const Text(
          "Add ToDo",
          style: TextStyle(color: Color(0xff596E79)),
        ),
        centerTitle: true,
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back,
            color: Color(0xff596E79),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 1, color: Colors.black),
                    color: const Color(0xffC7B198)),
                child: TextField(
                    decoration: const InputDecoration.collapsed(
                      hintText: "Title",
                      hintStyle: TextStyle(color: Color(0xff596E79)),
                    ),
                    onChanged: (text) {
                      setState(() {
                        if(text.isNotEmpty){
                          isEnabled = true;
                        }
                        else{
                          isEnabled = false;
                        }
                        title = text;
                      });
                    }),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 1, color: Colors.black),
                    color: const Color(0xffC7B198)),
                child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: "Description",
                        hintStyle: TextStyle(color: Color(0xff596E79))),
                    onChanged: (text) {
                      setState(() {
                        description = text;
                      });
                    }),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xffC7B198))),
                  onPressed: () {
                    if(isEnabled){
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Item added')));
                      widget.itemList?.add(TodoItem(
                          title: title,
                          description: description,
                          completed: false));
                      controller.putData(widget.itemList);
                    }
                    else{
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Cannot Add an Empty Task')));
                    }

                  },
                  child: Container(
                      child: const Text(
                    "Add item",
                    style: TextStyle(color: Color(0xff596E79)),
                  )))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xffC7B198),
        child: const Icon(Icons.book, color: Color(0xff596E79)),
      ),
    );
  }
}


class ItemPage extends StatelessWidget {
  const ItemPage({this.item,Key? key}) : super(key: key);

  final TodoItem? item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: item!.completed? Color(0xffC7B198) : Color(0xffDFD3C3),
      appBar: AppBar(
        backgroundColor: Color(0xff596E79),
        title: Text(item!.title!),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Text(item!.description!, style: TextStyle(fontSize: 20, color: item!.completed? Colors.white : Color(0xff596E79)),)
      ),
    );
  }
}

