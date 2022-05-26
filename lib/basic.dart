/// Basic example. Provider API is called within the same widget State where AnimatedList is built.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Users extends ChangeNotifier {
  final _list = ['0', '1', '2', '3', '4'];

  int get length => _list.length;

  operator [](index) => _list[index];

  int add() {
    final int index = length;
    _list.add('$index');
    notifyListeners();
    return index;
  }

  String removeAt(int index) {
    String user = _list.removeAt(index);
    notifyListeners();
    return user;
  }
}

class BasicApp extends StatelessWidget {
  const BasicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ChangeNotifierProvider(create: (_) => Users(), child: const AnimatedListDemo()));
  }
}

class AnimatedListDemo extends StatefulWidget {
  const AnimatedListDemo({Key? key}) : super(key: key);

  @override
  State<AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late Users users;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    users = Provider.of<Users>(context);
  }

  void addUser() {
    final int index = users.add();
    _listKey.currentState!.insertItem(index, duration: const Duration(seconds: 1));
  }

  void deleteUser(int index) {
    String user = users.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) {
        return SizeTransition(sizeFactor: animation, child: _buildItem(user));
      },
      duration: const Duration(seconds: 1),
    );
  }

  Widget _buildItem(String user, [int? removeIndex]) {
    return ListTile(
      key: ValueKey<String>(user),
      title: Text(user),
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      trailing: (removeIndex != null)
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteUser(removeIndex),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic AnimatedList Provider Demo'),
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: users.length,
        itemBuilder: (context, index, animation) {
          return FadeTransition(
            opacity: animation,
            child: _buildItem(users[index], index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        tooltip: 'Add an item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
