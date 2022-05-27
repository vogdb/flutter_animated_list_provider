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
        home: ChangeNotifierProvider(create: (_) => Users(), child: AnimatedListDemo()));
  }
}

class AnimatedListDemo extends StatelessWidget {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  AnimatedListDemo({Key? key}) : super(key: key);

  void addUser(Users users) {
    final int index = users.add();
    _listKey.currentState!.insertItem(index, duration: const Duration(seconds: 1));
  }

  void deleteUser(Users users, int index) {
    String user = users.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) {
        return SizeTransition(sizeFactor: animation, child: _buildItem(users, user));
      },
      duration: const Duration(seconds: 1),
    );
  }

  Widget _buildItem(Users users, String user, [int? removeIndex]) {
    return ListTile(
      key: ValueKey<String>(user),
      title: Text(user),
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      trailing: (removeIndex != null)
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteUser(users, removeIndex),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    Users users = Provider.of<Users>(context, listen: false);
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
            child: _buildItem(users, users[index], index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addUser(users),
        tooltip: 'Add an item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
