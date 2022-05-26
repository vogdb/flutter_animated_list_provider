/// Advanced example. Provider encapsulates AnimatedListState. This allows to call Provider API
/// outside of the widget State. AddButtonSeparateWidget demonstrates this feature.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef RemovedItemBuilder = Widget Function(
    String user, BuildContext context, Animation<double> animation);

class Users extends ChangeNotifier {
  final _list = ['0', '1', '2', '3', '4'];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  RemovedItemBuilder? _removedItemBuilder;

  int get length => _list.length;

  operator [](index) => _list[index];

  set removedItemBuilder(RemovedItemBuilder value) {
    _removedItemBuilder ??= value;
  }

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
        if (_removedItemBuilder == null) {
          throw Exception('Set `removedItemBuilder` field of `Users` class');
        }
        return _removedItemBuilder!(user, context, animation);
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
  late Users users;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    users = Provider.of<Users>(context);
    users.removedItemBuilder = (user, context, animation) {
      return SizeTransition(sizeFactor: animation, child: _buildItem(user));
    };
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
              onPressed: () => users.removeAt(removeIndex),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced AnimatedList Provider Demo'),
      ),
      body: AnimatedList(
        key: users.listKey,
        shrinkWrap: true,
        initialItemCount: users.length,
        itemBuilder: (context, index, animation) {
          return FadeTransition(
            opacity: animation,
            child: _buildItem(users[index], index),
          );
        },
      ),
      floatingActionButton: const AddButtonSeparateWidget(),
    );
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
