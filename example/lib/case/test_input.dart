import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key, this.title = "Input Test"}) : super(key: key);

  final String title;

  @override
  State<TestPage> createState() => _TestPageState();
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
                margin: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'You have pushed the button this many times:',
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const TextField(
                  minLines: 2,
                  maxLines: 10,
                ),
              ),
              TestTextField(),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.red,
                  width: double.infinity,
                  height: 128.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.orange,
                  width: double.infinity,
                  height: 128.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.green,
                  width: double.infinity,
                  height: 128.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue,
                  width: double.infinity,
                  height: 128.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.yellow,
                  width: double.infinity,
                  height: 128.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const TextField(
                  minLines: 2,
                  maxLines: 10,
                ),
              ),
              TestTextField(),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TestTextField extends StatefulWidget {
  @override
  State<TestTextField> createState() => _TestTextFieldState();
}

class _TestTextFieldState extends State<TestTextField> {
  FocusNode? _node;
  PersistentBottomSheetController? _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _node = FocusNode();
    _node!.addListener(() {
      if (_node!.hasFocus) {
        debugPrint('showBottomSheet');
        _controller = Scaffold.of(context)
            .showBottomSheet<dynamic>((BuildContext ctx) => Container(
                  width: double.infinity,
                  height: 36.0,
                  color: Colors.deepPurple,
                ));
      } else {
        debugPrint('closeBottomSheet');
        _controller!.close();
        _controller = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        minLines: 2,
        maxLines: 10,
        focusNode: _node,
      ),
    );
  }
}
