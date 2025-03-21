import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/screens/home_page.dart';
import 'package:intl/intl.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _productController =
      TextEditingController(); // Stores food type input
  final TextEditingController _quantityController =
      TextEditingController(); // Stores quantity input
  DateTime? _selectedDate; // Stores the selected date

  String? _selectedTradePoint; // Stores dropdown selection for trade point
  String? _donateOrTrade; // Stores dropdown selection for donation trade

  void _submitItem() {
    if (_productController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    print(
      'Item Added: ${_productController.text}, Exp: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
    );
  }

  // Function to show Date Picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  // Custom input field style
  /*InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: const Color.fromARGB(80, 255, 213, 63),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        borderSide: BorderSide.none, // No border lines
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(150, 222, 79, 79), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(213, 222, 79, 79)),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hand2Hand',
          style: GoogleFonts.outfit(
            fontSize: 26,
            color: Color.fromARGB(255, 222, 79, 79),
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputRow('PRODUCT', _productController),
            _buildInputRow('QUANTITY', _quantityController),
            _buildDateRow('EXP. DATE'),
            _buildDropDownButton('DONATE/TRADE', ['Donate', 'Trade'], (value) {
              setState(() {
                _donateOrTrade = value;
              });
            }, _donateOrTrade),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150, // Fixed width for labels
            child: Text(
              label,
              style: GoogleFonts.redHatDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 66, 66, 66),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none, // No borders
                hintText: 'Enter ${label.toLowerCase()}',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Date Picker Row
  Widget _buildDateRow(String label) {
    return GestureDetector(
      onTap: _selectDate,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: GoogleFonts.redHatDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 66, 66, 66),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDownButton(
    String label,
    List<String> options,
    ValueChanged<String?> onChanged,
    String? selectedValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: GoogleFonts.redHatDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 66, 66, 66),
              ),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              hint: Text('Select'),
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
              alignment: Alignment.centerRight,
              items:
                  options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          option,
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
