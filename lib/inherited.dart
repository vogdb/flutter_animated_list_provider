/// InheritedNotifier example. No Provider. The same approach as in Advanced. AnimatedList key and
/// its removedItemBuilder are within InheritedNotifier.

import 'package:flutter/material.dart';

typedef RemovedItemBuilder = Widget Function(
    String user, BuildContext context, Animation<double> animation);

class Users extends ChangeNotifier {
  Users({
    required RemovedItemBuilder removedItemBuilder,
    required GlobalKey<AnimatedListState> listKey,
  })  : _removedItemBuilder = removedItemBuilder,
        _listKey = listKey;

  final List _list = [];
  final GlobalKey<AnimatedListState> _listKey;
  final RemovedItemBuilder _removedItemBuilder;

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

class UsersInheritedNotifier extends InheritedNotifier<Users> {
  const UsersInheritedNotifier({
    Key? key,
    required Users notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static Users of(BuildContext context, [bool listen = true]) {
    UsersInheritedNotifier notifier = (listen
            ? context.dependOnInheritedWidgetOfExactType<UsersInheritedNotifier>()
            : context.findAncestorWidgetOfExactType<UsersInheritedNotifier>())
        as UsersInheritedNotifier;
    return notifier.notifier!;
  }
}

class InheritedApp extends StatelessWidget {
  const InheritedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: UsersInheritedNotifier(
      notifier: Users(
        listKey: GlobalKey<AnimatedListState>(),
        removedItemBuilder: (user, context, animation) {
          return SizeTransition(sizeFactor: animation, child: AnimatedListItem(user: user));
        },
      ),
      child: const AnimatedListDemo(),
    ));
  }
}

class AnimatedListDemo extends StatelessWidget {
  const AnimatedListDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'InheritedNotifier AnimatedList Demo, ${UsersInheritedNotifier.of(context).length}.'),
      ),
      body: AnimatedList(
        key: UsersInheritedNotifier.of(context, false).listKey,
        shrinkWrap: true,
        initialItemCount: UsersInheritedNotifier.of(context).length,
        itemBuilder: (context, index, animation) {
          return FadeTransition(
            opacity: animation,
            child: AnimatedListItem(
                user: UsersInheritedNotifier.of(context)[index], removeIndex: index),
          );
        },
      ),
      floatingActionButton: const AddButtonSeparateWidget(),
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    Key? key,
    required this.user,
    this.removeIndex,
  }) : super(key: key);
  final String user;
  final int? removeIndex;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey<String>(user),
      title: Text(user),
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      trailing: (removeIndex != null)
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => UsersInheritedNotifier.of(context, false).removeAt(removeIndex!),
            )
          : null,
    );
  }
}

class AddButtonSeparateWidget extends StatelessWidget {
  const AddButtonSeparateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: UsersInheritedNotifier.of(context, false).add,
      tooltip: 'Add an item',
      child: const Icon(Icons.add),
    );
  }
}
