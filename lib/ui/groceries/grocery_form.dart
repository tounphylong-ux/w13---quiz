import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/grocery.dart';

Uuid uuid = const Uuid();

class GroceryForm extends StatefulWidget {
  const GroceryForm({super.key, this.grocery});

  final Grocery? grocery;

  @override
  State<GroceryForm> createState() {
    return _GroceryFormState();
  }
}

class _GroceryFormState extends State<GroceryForm> {
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Default settings
  static const defautName = "New grocery";
  static const defaultQuantity = 1;
  static const defaultCategory = GroceryCategory.fruit;

  // Inputs
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  late GroceryCategory _selectedCategory;
  late GroceryCategory _initialCategory;
  late String _initialName;
  late int _initialQuantity;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();

    _isEditing = widget.grocery != null;
    _initialName = widget.grocery?.name ?? defautName;
    _initialQuantity = widget.grocery?.quantity ?? defaultQuantity;
    _initialCategory = widget.grocery?.category ?? defaultCategory;

    // Initialize inputs with default or edited values
    _nameController.text = _initialName;
    _quantityController.text = _initialQuantity.toString();
    _selectedCategory = _initialCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void onReset() {
    // Reset all fields to the initial values
    _formKey.currentState?.reset();
    setState(() {
      _nameController.text = _initialName;
      _quantityController.text = _initialQuantity.toString();
      _selectedCategory = _initialCategory;
    });
  }

  void onSubmit() {
    if (_formKey.currentState!.validate()) {
      final parsedQuantity = int.parse(_quantityController.text);
      // Create and return the new grocery
      Grocery newGrocery = Grocery(
        id: widget.grocery?.id ?? uuid.v4(),
        name: _nameController.text,
        quantity: parsedQuantity,
        category: _selectedCategory,
      );

      Navigator.pop<Grocery>(context, newGrocery);
    }
  }

  String? validateName(String? value) {

    if (value == null || value.isEmpty) {
      return "Enter a name";
    }

    if (value.length < 10 || value.length > 50) {
      return "Enter a text btw 10 to 50 characters";
    }

    return null;  //valid
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter a quantity";
    }

    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return "Enter a valid positive number";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit item' : 'Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: validateName,
                controller: _nameController,
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: validateQuantity,
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<GroceryCategory>(
                      initialValue: _selectedCategory,
                      items: GroceryCategory.values
                          .map(
                            (g) => DropdownMenuItem<GroceryCategory>(
                              value: g,
                              child: Row(
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    color: g.color,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(g.label),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: onReset, child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: onSubmit,
                    child: Text(_isEditing ? 'Edit Item' : 'Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
