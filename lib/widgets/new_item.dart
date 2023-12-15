import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';

class New_Item extends StatefulWidget {
  const New_Item({super.key});

  @override
  State<New_Item> createState() => _New_ItemState();
}

class _New_ItemState extends State<New_Item> {
  final _formkey = GlobalKey<FormState>();
  var _enteredvalue = '';
  var _enteredquantity = 1;
  var _enteredcategory = categories[Categories.vegetables]!;
  var issending = false;
  void _saveitem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        issending = true;
      });
      final url = Uri.https('flutter-prep-a3687-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _enteredvalue,
          'quantity': _enteredquantity,
          'category': _enteredcategory.title
        }),
      );
      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> respdata = jsonDecode(response.body);
      Navigator.of(context).pop(GroceryItem(
          id: respdata['name'],
          name: _enteredvalue,
          quantity: _enteredquantity,
          category: _enteredcategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'The characters must be between 1 and 50.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredvalue = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      initialValue: _enteredquantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 0) {
                          return 'It must be a valid Integer.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredquantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      value: _enteredcategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem<Category>(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _enteredcategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: issending
                        ? null
                        : () {
                            _formkey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: issending ? null : _saveitem,
                    child: issending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
