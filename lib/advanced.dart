/// Advanced example. Provider encapsulates AnimatedList key and its removedItemBuilder. This
/// allows to call Provider API outside of the widget that builds AnimatedList.
/// AddButtonSeparateWidget demonstrates this feature.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef RemovedItemBuilder = Widget Function(
    String user, BuildContext context, Animation<double> animation);

class Users extends ChangeNotifier {
  final _list = ['0', '1', '2', '3', '4'];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final RemovedItemBuilder _removedItemBuilder;

  Users(this._removedItemBuilder);

  int get length => _list.length;

  operator [](index) => _list[index];

  GlobalKey<AnimatedListState> get listKey => _listKey;

  int add() {
    final int index = length;
    _list.add('$index');
    _listKey.currentState!.insertItem(index, duration: const Duration(seconds: 1));
    notifyListeners();
    return index;
  }

  String removeAt(int index) {
    String user = _list.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return _removedItemBuilder(user, context, animation);
      },
      duration: const Duration(seconds: 1),
    );
    notifyListeners();
    return user;
  }
}

class AdvancedApp extends StatelessWidget {
  const AdvancedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AnimatedListDemo());
  }
}

class AnimatedListDemo extends StatelessWidget {
  const AnimatedListDemo({Key? key}) : super(key: key);

  Widget _buildItem(BuildContext context, String user, [int? removeIndex]) {
    Users users = Provider.of<Users>(context, listen: false);
    return ListTile(
      key: ValueKey<String>(user),
      title: Text(user),
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      trailing: (removeIndex != null)
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => users.removeAt(removeIndex),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => Users((user, context, animation) {
      return SizeTransition(sizeFactor: animation, child: _buildItem(context, user));
    }), child: Scaffold(
      appBar: AppBar(
        title: const Text('Advanced AnimatedList Provider Demo'),
      ),
      body: Consumer<Users>(builder: (BuildContext context, Users users, _){
        return AnimatedList(
          key: users.listKey,
          shrinkWrap: true,
          initialItemCount: users.length,
          itemBuilder: (context, index, animation) {
            return FadeTransition(
              opacity: animation,
              child: _buildItem(context, users[index], index),
            );
          },
        );
      }),
      floatingActionButton: const AddButtonSeparateWidget(),
    ));
  }
}

class AddButtonSeparateWidget extends StatelessWidget {
  const AddButtonSeparateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users users = Provider.of<Users>(context, listen: false);
    return FloatingActionButton(
      onPressed: users.add,
      tooltip: 'Add an item',
      child: const Icon(Icons.add),
    );
  }
}
