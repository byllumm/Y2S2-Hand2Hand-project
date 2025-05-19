import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/screens/itemDetail_page.dart';

class ExploreItems extends StatefulWidget {
  const ExploreItems({super.key});

  @override
  _ExploreItemsState createState() => _ExploreItemsState();
}

class _ExploreItemsState extends State<ExploreItems> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService().streamOtherUsersItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No items to explore yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final filteredItems =
            items.where((item) {
              final category = item['category'] ?? '';
              final name = (item['name'] ?? '').toString().toLowerCase();
              final matchesCategory =
                  selectedCategory == null || selectedCategory == category;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  name.contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) {
                        setState(() {
                          _searchQuery = _searchController.text;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                                : null,
                      ),
                    ),
                  ),

                  // Filter button
                  IconButton(
                    icon: const Icon(Icons.filter_alt_outlined),
                    iconSize: 35,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListView(
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                title: const Text('Clear Filter'),
                                onTap: () {
                                  setState(() {
                                    selectedCategory = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(),
                              ...[
                                'Dairy',
                                'Drinks',
                                'Fish',
                                'Fruits',
                                'Grains',
                                'Meat',
                                'Sweets',
                                'Vegetables',
                                'Other',
                              ].map(
                                (category) => ListTile(
                                  title: Text(category),
                                  selected: selectedCategory == category,
                                  selectedTileColor: Colors.grey.withOpacity(0.8),
                                  selectedColor: Colors.white,
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            // If no items match the selected category, show a message
            if (filteredItems.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No items found!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                    });
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailPage(item: item),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child:
                                      item['image'] != null
                                          ? Image.network(
                                            item['image'],
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                          : const Icon(Icons.image_not_supported),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  item['name'] ?? 'Unnamed',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
