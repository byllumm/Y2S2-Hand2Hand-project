import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/city_map.dart';
import 'package:intl/intl.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:latlong2/latlong.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  bool _isSubmitting = false;
  final TextEditingController _productController =
      TextEditingController(); // Stores food type input
  final TextEditingController _moreInfoController = TextEditingController();
  DateTime? _selectedDate; // Stores the selected date
  String? _selectedTradePoint; // Stores dropdown selection for trade point
  String? _donateOrTrade; // Stores dropdown selection for donation trade
  String? _selectedCategory; // Stores dropdown selection for category
  File? _selectedImage;
  final TextEditingController _quantityController = TextEditingController();
  LatLng? _selectedTradePointCoordinates; // Add this to store coordinates

  final List<String> _categories = [
    'Dairy',
    'Drinks',
    'Fish',
    'Fruits',
    'Grains',
    'Meat',
    'Sweets',
    'Vegetables',
    'Other',
  ];

  @override
  void dispose() async {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTradePoint() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (selectedLocation != null && mounted) {
      setState(() {
        _selectedTradePoint = selectedLocation['address'];
        _selectedTradePointCoordinates = selectedLocation['coordinates'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showActionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Action',
            textAlign: TextAlign.center,
            style: GoogleFonts.redHatDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 66, 66, 66),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Donate',
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _donateOrTrade = 'Donate';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'Trade',
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _donateOrTrade = 'Trade';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Category',
            textAlign: TextAlign.center,
            style: GoogleFonts.redHatDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 66, 66, 66),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                _categories.map((category) {
                  return ListTile(
                    title: Text(
                      category,
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _submitItem() async {
    // Print the current value of the quantity controller for debugging
    print("QuantityController Text: '${_quantityController.text}'");

    if (_productController.text.isEmpty ||
        _selectedDate == null ||
        _donateOrTrade == null ||
        _selectedTradePoint == null ||
        _selectedCategory == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all the required fields',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(235, 222, 79, 79),
        ),
      );
      return;
    }

    // Validate and parse quantity
    int quantity;
    try {
      // Parse the value as a double and convert it to an integer
      quantity = double.parse(_quantityController.text.trim()).toInt();
      if (quantity <= 0) {
        throw FormatException("Quantity must be greater than zero");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid quantity. Please enter a valid number.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(235, 222, 79, 79),
        ),
      );
      return;
    }

    final supabaseService = SupabaseService();

    try {
      await supabaseService.addItem(
        _productController.text, // Name
        quantity, // Quantity
        _selectedDate!, // Expiration Date
        _donateOrTrade == 'Trade' ? 1 : 0, // Action: 1 for Trade, 0 for Offer
        _selectedTradePointCoordinates?.latitude ?? 0.0, // Latitude
        _selectedTradePointCoordinates?.longitude ?? 0.0, // Longitude
        _moreInfoController.text, // Description
        _selectedImage!, // Image File
        _selectedCategory,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your product was submitted successfully!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(233, 65, 173, 69),
        ),
      );

      // Reset the form
      setState(() {
        _productController.clear();
        _quantityController.clear();
        _selectedDate = null;
        _donateOrTrade = null;
        _selectedTradePoint = null;
        _selectedImage = null;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding item: $e',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(235, 222, 79, 79),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'ITEM LISTING',
          style: GoogleFonts.outfit(
            fontSize: 24,
            color: Color.fromARGB(255, 222, 79, 79),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: DottedBorder(
                    color: Color.fromARGB(223, 255, 213, 63),
                    strokeWidth: 1.5,
                    dashPattern: [8, 4],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(12),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(130, 255, 241, 191),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          _selectedImage != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'UPLOAD PICTURE',
                                    style: GoogleFonts.redHatDisplay(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(178, 66, 66, 66),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Product
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 150, // Fixed width for labels
                    child: Text(
                      'PRODUCT',
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _productController,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none, // No borders
                        hintText: 'Enter product name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quantity
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      "QUANTITY",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                  InputQty(
                    initVal: 0,
                    minVal: 1,
                    validator: (value) {
                      if (value == null) {
                        return "Required field";
                      } else if (value >= 200) {
                        return "More than allowed quantity";
                      }
                      return null;
                    },
                    onQtyChanged: (value) {
                      // Update the _quantityController text whenever the quantity changes
                      _quantityController.text = value.toString();
                    },
                    decoration: QtyDecorationProps(
                      btnColor: Color.fromARGB(223, 255, 213, 63),
                      width: 20,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    qtyFormProps: QtyFormProps(
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expiration Date
            GestureDetector(
              onTap: _selectDate,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'EXP. DATE',
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
                            color:
                                _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Donate or Trade options
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      'ACTION',
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: GestureDetector(
                      onTap: () => _showActionPopup(context),
                      child: Container(
                        height: 42,
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _donateOrTrade ?? 'Select Action',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    _donateOrTrade == null
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category options
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      'CATEGORY',
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: GestureDetector(
                      onTap: () => _showCategoryPopup(context),
                      child: Container(
                        height: 42,
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory ?? 'Select Category',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    _selectedCategory == null
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Trade Point
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      'TRADE POINT',
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTradePoint,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedTradePoint ?? 'Choose on Map',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  _selectedTradePoint == null
                                      ? Colors.grey
                                      : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8), // Space between text and icon
                          Icon(
                            Icons.map,
                            color: Color.fromARGB(255, 222, 79, 79),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // More Info (Optional)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 150, // Keep labels aligned
                    child: Text(
                      'MORE INFO',
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _moreInfoController,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none, // No borders
                        hintText: 'Optional',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Submit Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () async {
                              setState(() => _isSubmitting = true);
                              await Future.delayed(Duration(seconds: 1));
                              _submitItem();
                              setState(() => _isSubmitting = false);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(200, 222, 79, 79),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'SUBMIT',
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
