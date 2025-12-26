import 'package:flutter/material.dart';
import '../../data/mock_grocery_repository.dart';
import '../../models/grocery.dart';
import 'grocery_form.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  int _currentTabIndex = 0;

  // CREATE new grocery
  void onCreate() async {
    Grocery? newGrocery = await Navigator.push<Grocery>(
      context,
      MaterialPageRoute(builder: (context) => const GroceryForm()),
    );

    if (newGrocery != null) {
      setState(() {
        dummyGroceryItems.add(newGrocery);
      });
    }
  }

  // DELETE grocery (used ONLY in Search tab)
  void onDelete(Grocery grocery) {
    setState(() {
      dummyGroceryItems.removeWhere((item) => item.id == grocery.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: onCreate, icon: const Icon(Icons.add))],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          const GroceriesTab(),
          SearchTab(onDelete: onDelete),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: 'Groceries',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}

class SearchTab extends StatefulWidget {
  const SearchTab({super.key, required this.onDelete});

  final void Function(Grocery grocery) onDelete;

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String searchText = '';

  List<Grocery> get filteredList {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) return List<Grocery>.from(dummyGroceryItems);

    return dummyGroceryItems
        .where((g) => g.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search grocery...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final grocery = filteredList[index];
                return Dismissible(
                  key: ValueKey(grocery.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => widget.onDelete(grocery),
                  child: GroceryTile(grocery: grocery),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GroceriesTab extends StatelessWidget {
  const GroceriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (dummyGroceryItems.isEmpty) {
      return const Center(child: Text('No items added yet.'));
    }

    return ListView.builder(
      itemCount: dummyGroceryItems.length,
      itemBuilder: (context, index) {
        final grocery = dummyGroceryItems[index];
        return GroceryTile(grocery: grocery);
      },
    );
  }
}

class GroceryTile extends StatelessWidget {
  const GroceryTile({super.key, required this.grocery});

  final Grocery grocery;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(width: 15, height: 15, color: grocery.category.color),
      title: Text(grocery.name),
      trailing: Text(grocery.quantity.toString()),
    );
  }
}
