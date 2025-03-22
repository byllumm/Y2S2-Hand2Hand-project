import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String, String, DateTime, int, String) onAdd;

  AddItemDialog({required this.onAdd});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  DateTime expirationDate = DateTime.now();
  int quantity = 1;
  String category = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value!,
                validator:
                    (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onSaved: (value) => quantity = int.parse(value!),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a quantity' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                onSaved: (value) => category = value!,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a category' : null,
              ),
              SizedBox(height: 10),
              Text('Expiration Date: ${expirationDate.toLocal()}'),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: expirationDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      expirationDate = pickedDate;
                    });
                  }
                },
                child: Text('Pick Expiration Date'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onAdd(
                name,
                description,
                expirationDate,
                quantity,
                category,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
