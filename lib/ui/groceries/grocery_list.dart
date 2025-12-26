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
  int _currenTabIndex = 0; // by default

  void onCreate() async {
    // Navigate to the form screen using the Navigator push
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

  void onEdit(Grocery grocery) async {
    final Grocery? updatedGrocery = await Navigator.push<Grocery>(
      context,
      MaterialPageRoute(builder: (context) => GroceryForm(grocery: grocery)),
    );
    if (updatedGrocery != null) {
      setState(() {
        final index =
            dummyGroceryItems.indexWhere((element) => element.id == updatedGrocery.id);
        if (index != -1) {
          dummyGroceryItems[index] = updatedGrocery;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: onCreate, icon: const Icon(Icons.add))],
      ),

      body: IndexedStack(
        index: _currenTabIndex,
        children: [
          GroceriesTab(onEdit: onEdit),
          SeearchTab(onEdit: onEdit),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: _currenTabIndex,
        onTap: (index) {
          setState(() {
            _currenTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: 'Groceries',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Groceries'),
        ],
      ),
    );
  }
}

class SeearchTab extends StatefulWidget {
  const SeearchTab({super.key, required this.onEdit});

  final void Function(Grocery grocery) onEdit;

  @override
  State<SeearchTab> createState() => _SeearchTabState();
}

class _SeearchTabState extends State<SeearchTab> {
  String searchText = "";

  void onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
  }

  List<Grocery> get filteredList {
    List<Grocery> result = [];
    for(Grocery g in dummyGroceryItems) {
      if (g.name.startsWith(searchText)) {
        result.add(g);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextField(onChanged: onSearchChanged),
          SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) => GroceryTile(
                grocery: filteredList[index],
                onTap: () => widget.onEdit(filteredList[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroceriesTab extends StatelessWidget {
  const GroceriesTab({super.key, required this.onEdit});

  final void Function(Grocery grocery) onEdit;

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (dummyGroceryItems.isNotEmpty) {
      //  Display groceries with an Item builder and  LIst Tile
      content = ListView.builder(
        itemCount: dummyGroceryItems.length,
        itemBuilder: (context, index) =>
            GroceryTile(
          grocery: dummyGroceryItems[index],
          onTap: () => onEdit(dummyGroceryItems[index]),
        ),
      );
    }
    return content;
  }
}

class GroceryTile extends StatelessWidget {
  const GroceryTile({super.key, required this.grocery, this.onTap});

  final Grocery grocery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(width: 15, height: 15, color: grocery.category.color),
      title: Text(grocery.name),
      trailing: Text(grocery.quantity.toString()),
      onTap: onTap,
    );
  }
}
