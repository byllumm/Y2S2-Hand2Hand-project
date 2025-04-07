import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String, int, DateTime, String, String, String) onAdd;

  const AddItemDialog({super.key, required this.onAdd});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String details = '';
  DateTime expirationDate = DateTime.now();
  int quantity = 1;
  String action = '';
  String tradePoint = '';

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
                decoration: InputDecoration(labelText: 'Details'),
                onSaved: (value) => details = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onSaved: (value) => quantity = int.tryParse(value!) ?? 1,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a quantity' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Action'),
                onSaved: (value) => action = value!,
                validator:
                    (value) => value!.isEmpty ? 'Please enter an action' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Trade Point'),
                onSaved: (value) => tradePoint = value!,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a trade point' : null,
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
                quantity,
                expirationDate,
                action,
                tradePoint,
                details,
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
