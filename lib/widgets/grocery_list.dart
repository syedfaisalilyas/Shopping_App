import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/data/dummy_items.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class Grocery_List extends StatefulWidget {
  const Grocery_List({super.key});

  @override
  State<Grocery_List> createState() => _Grocery_ListState();
}

class _Grocery_ListState extends State<Grocery_List> {
  List<GroceryItem> grocerylist = [];
  var _loading = true;
  String? error;
  @override
  void initState() {
    loaditem();
    super.initState();
  }

  void loaditem() async {
    final url = Uri.https(
        'flutter-prep-a3687-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          error = "Failed to fetch data.Please try again later";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _loading = false;
        });
        return;
      }
      final Map<String, dynamic> listdata = json.decode(response.body);
      final List<GroceryItem> _loadeditems = [];
      for (final item in listdata.entries) {
        final category = categories.entries
            .firstWhere(
                (catitem) => catitem.value.title == item.value['category'])
            .value;
        _loadeditems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        grocerylist = _loadeditems;
        _loading = false;
      });
    } catch (err) {
      setState(() {
        error = "Something went wrong.Please try again later";
      });
    }
  }

  void _additem() async {
    final new_item = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const New_Item(),
      ),
    );

    if (new_item == null) {
      return;
    }
    setState(() {
      grocerylist.add(new_item);
    });
  }

  void _removeitem(GroceryItem item) async {
    final indexx = groceryItems.indexOf(item);
    setState(() {
      grocerylist.remove(item);
    });
    final url = Uri.https('flutter-prep-a3687-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        grocerylist.insert(indexx, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added till yet'),
    );
    if (_loading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (grocerylist.isNotEmpty) {
      content = ListView.builder(
          itemCount: grocerylist.length,
          itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removeitem(grocerylist[index]);
                },
                key: ValueKey(grocerylist[index].id),
                child: ListTile(
                  title: Text(grocerylist[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: grocerylist[index].category.color,
                  ),
                  trailing: Text(grocerylist[index].quantity.toString()),
                ),
              ));
    }
    if (error != null) {
      content = Center(
        child: Text(error!),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
                onPressed: () {
                  _additem();
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
