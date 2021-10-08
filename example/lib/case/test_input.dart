import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title = "Input Test"}) : super(key: key);

  final String title;

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
          bottom: false,
          child: ListView(
            children: <Widget>[
              Container(
                child: Text(
                  'You have pushed the button this many times:',
                ),
                margin: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
              ),
              Container(
                child: Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                margin: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
              ),
              Container(
                child: TextField(
                  minLines: 2,
                  maxLines: 10,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              TestTextField(),
              Container(
                child: Container(
                  color: Colors.red,
                  width: double.infinity,
                  height: 128.0,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: Container(
                  color: Colors.orange,
                  width: double.infinity,
                  height: 128.0,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: Container(
                  color: Colors.green,
                  width: double.infinity,
                  height: 128.0,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: Container(
                  color: Colors.blue,
                  width: double.infinity,
                  height: 128.0,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: Container(
                  color: Colors.yellow,
                  width: double.infinity,
                  height: 128.0,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: TextField(
                  minLines: 2,
                  maxLines: 10,
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              TestTextField(),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TestTextField extends StatefulWidget {
  @override
  _TestTextFieldState createState() => _TestTextFieldState();
}

class _TestTextFieldState extends State<TestTextField> {
  FocusNode _node;
  PersistentBottomSheetController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _node = FocusNode();
    _node.addListener(() {
      if (_node.hasFocus) {
        print('showBottomSheet');
        _controller = Scaffold.of(context)
            .showBottomSheet<dynamic>((BuildContext ctx) => Container(
                  width: double.infinity,
                  height: 36.0,
                  color: Colors.deepPurple,
                ));
      } else {
        if (_controller != null) {
          //Navigator.of(context).pop();
          print('closeBottomSheet');
          _controller.close();
        }
        _controller = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        minLines: 2,
        maxLines: 10,
        focusNode: _node,
      ),
      padding: const EdgeInsets.all(8.0),
    );
  }
}
