import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class SimpleWidget extends StatefulWidget {
  final Map? params;
  final String messages;
  final String? uniqueId;

  const SimpleWidget(this.uniqueId, this.params, this.messages);

  @override
  State<SimpleWidget> createState() => _SimpleWidgetState();
}

class _SimpleWidgetState extends State<SimpleWidget>
    with PageVisibilityObserver {
  static const String _kTag = 'page_visibility';
  @override
  void didChangeDependencies() {
    PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context)!);
    debugPrint('$_kTag#didChangeDependencies, ${widget.uniqueId}, $this');
    super.didChangeDependencies();
  }

  @override
  void initState() {
    debugPrint('$_kTag#initState, ${widget.uniqueId}, $this');
    super.initState();
  }

  @override
  void dispose() {
    PageVisibilityBinding.instance.removeObserver(this);
    debugPrint('$_kTag#dispose, ${widget.uniqueId}, $this');
    super.dispose();
  }

  @override
  void onPageShow() {
    debugPrint('$_kTag#onPageShow, ${widget.uniqueId}, $this');
  }

  @override
  void onPageHide() {
    debugPrint('$_kTag#onPageHide, ${widget.uniqueId}, $this');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tab_example'),
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 80.0),
                alignment: AlignmentDirectional.center,
                child: Text(
                  widget.messages,
                  style: const TextStyle(fontSize: 28.0, color: Colors.blue),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(top: 32.0),
                alignment: AlignmentDirectional.center,
                child: Text(
                  widget.uniqueId!,
                  style: const TextStyle(fontSize: 16.0, color: Colors.red),
                ),
              ),
              const CupertinoTextField(
                prefix: Icon(
                  CupertinoIcons.person_solid,
                  color: CupertinoColors.lightBackgroundGray,
                  size: 28.0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.words,
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: const Text(
                      'open native page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push("native"),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: const Text(
                      'open flutter page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push("flutterPage",
                    arguments: <String, String?>{'from': widget.uniqueId}),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: const Text(
                      'open flutter page with FlutterView',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push("flutterPage",
                    withContainer: true,
                    arguments: <String, String?>{'from': widget.uniqueId}),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: const Text(
                      'Navigator.push',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Navigator.push')),
                      body: Center(
                        child: TextButton(
                          child: const Text('POP'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                )),
              ),
              const SizedBox(
                height: 300,
                width: 200,
                child: Text(
                  '',
                  style: TextStyle(fontSize: 22.0, color: Colors.black),
                ),
              )
            ],
          ))),
    );
  }
}
