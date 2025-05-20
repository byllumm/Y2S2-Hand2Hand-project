import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/screens/chatscreen_page.dart';
import 'package:hand2hand/screens/trade_point.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Map<String, dynamic>? donorInfo;
  bool _requestMade = false;
  bool _isLoading = false;
  bool _isOwnItem = false;

  @override
  void initState() {
    super.initState();
    fetchDonorInfo();

    _checkIfRequested();

    final currentUserId = SupabaseService().currentUserId;
    _isOwnItem = currentUserId == widget.item['user_id'];
  }

  Future<void> _checkIfRequested() async {
    try {
      final status = await SupabaseService().getItemStatus(widget.item['id']);
      if (mounted) {
        setState(() {
          _requestMade = status['is_requested'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking item status: $e');
    }
  }

  Future<void> fetchDonorInfo() async {
    final donor = await SupabaseService().getUserById(widget.item['user_id']);
    if (mounted) {
      setState(() {
        donorInfo = donor;
      });
    }
  }

  void _handleRequest() async {
    if (_requestMade || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // First check if user is trying to request their own item
      final currentUserId = SupabaseService().currentUserId;
      if (currentUserId == widget.item['user_id']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot request your own item')),
        );
        return;
      }

      final status = await SupabaseService().getItemStatus(widget.item['id']);
      print('Item status: $status'); // Debug log

      if (!status['available']) {
        String message = 'Item not available';
        if (status['is_requested']) {
          message = 'Item already requested by someone else';
        } else if (status['is_deleted']) {
          message = 'Item has been deleted';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final success = await SupabaseService().requestItem(widget.item['id']);
      print('Request success: $success'); // Debug log

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item requested successfully')),
        );
        setState(() {
          _requestMade = true;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to request item')));
      }
    } catch (e) {
      print('Error during request: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sendMessage() {
    final receiverId = widget.item['user_id'];
    final itemId = widget.item['id'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(itemId: itemId, receiverId: receiverId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F5),
      appBar: AppBar(
        title: Text(
          "ITEM DETAILS",
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 222, 79, 79),
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  item['image'] != null
                      ? Image.network(
                        item['image'],
                        height: screenHeight * 0.25,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: screenHeight * 0.25,
                        color: Colors.grey,
                      ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? "Item",
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            color: Color.fromARGB(255, 66, 66, 66),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow("QUANTITY", item['quantity'].toString()),
                    const SizedBox(height: 10),
                    infoRow(
                      "TRADE POINT",
                      "Selected",
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TradePoint(
                                    latitude: item['latitude'],
                                    longitude: item['longitude'],
                                    imageUrl: item['image'],
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          "See >",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    infoRow("EXP. DATE", item['expirationDate'] ?? ''),
                    const SizedBox(height: 10),
                    infoRow("CATEGORY", item['category'] ?? ''),
                    const SizedBox(height: 20),
                    // Description
                    Text(
                      "DESCRIPTION",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['description'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Donor info
                    if (donorInfo != null) ...[
                      Text(
                        "DONOR",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "NAME: ${donorInfo!['name']}",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "USERNAME: @${donorInfo!['username']}",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                    ],

                    const SizedBox(height: 100),

                    // Buttons
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          children: [
                            if (!_isOwnItem)
                              OutlinedButton(
                                onPressed: _sendMessage,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color.fromARGB(
                                    223,
                                    255,
                                    213,
                                    63,
                                  ),
                                  backgroundColor: Color.fromARGB(
                                    223,
                                    247,
                                    247,
                                    231,
                                  ),
                                  side: const BorderSide(
                                    color: Color.fromARGB(223, 255, 213, 63),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width,
                                    0,
                                  ),
                                ),
                                child: Text(
                                  "Send a Message",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed:
                                  _isLoading || _requestMade
                                      ? null
                                      : _handleRequest,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                backgroundColor:
                                    _requestMade
                                        ? Colors.grey
                                        : const Color.fromARGB(
                                          223,
                                          255,
                                          213,
                                          63,
                                        ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width,
                                  0,
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        _requestMade ? "REQUESTED" : "REQUEST",
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Color.fromARGB(255, 66, 66, 66),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing ??
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
      ],
    );
  }
}
