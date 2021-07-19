import 'package:flutter/material.dart';

class StateRestorationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RootRestorationScope(
        restorationId: 'root_id',
        child: MaterialApp(
          title: 'State Restoration Demo',
          home: StateRestorationPage(),
        ));
  }
}

class StateRestorationPage extends StatefulWidget {
  const StateRestorationPage({Key key}) : super(key: key);

  @override
  _StateRestorationPageState createState() => _StateRestorationPageState();
}

class _StateRestorationPageState extends State<StateRestorationPage>
    with RestorationMixin {
  RestorableInt _index = RestorableInt(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StateRestorationDemo'),
      ),
      body: Container(
        color: Colors.primaries[_index.value],
        child: Center(
            child: Text(
          'Index is ${_index.value}.',
          style: TextStyle(fontSize: 22.0, color: Colors.black),
        )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index.value,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: (index) => setState(() => _index.value = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  @override
  // The restoration bucket id for this page,
  // let's give it the name of our page!
  String get restorationId => 'StateRestorationDemo';

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    // Register our property to be saved every time it changes,
    // and to be restored every time our app is killed by the OS!
    registerForRestoration(_index, 'nav_bar_index');
  }
}
