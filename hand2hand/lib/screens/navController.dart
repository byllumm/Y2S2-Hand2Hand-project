import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/navigation_helper.dart';
import 'package:hand2hand/screens/add_item_page.dart';
import 'package:hand2hand/screens/explorer_page.dart';
import 'package:hand2hand/screens/chatlist_page.dart';
import 'package:hand2hand/screens/my_items_screen.dart';
import 'package:hand2hand/screens/profile_screen.dart';
import 'package:hand2hand/screens/notifications_page.dart';
import 'package:hand2hand/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _lastIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExploreItems(),
      Container(),
      NotificationsPage(onTabChange: _onTabChange, supabaseService: SupabaseService(),),
      ProfileScreen(onTabChange: _onTabChange),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _lastIndex = _selectedIndex;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddItemPage()),
      ).then((_) {
        setState(() {
          _selectedIndex = _lastIndex;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Hand2Hand',
            style: GoogleFonts.outfit(
              fontSize: 26,
              color: Color.fromARGB(255, 222, 79, 79),
            ),
          ),
          backgroundColor: Color.fromARGB(223, 255, 213, 63),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.mail, color: Color.fromARGB(255, 222, 79, 79)),
              onPressed: () {
                navigateWithTransition(context, ChatListPage());
              }
            )
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color.fromARGB(255, 222, 79, 79),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Item'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
