import 'package:flutter/material.dart';

class SafeAreaPage extends StatefulWidget {
  const SafeAreaPage({Key? key}) : super(key: key);

  @override
  State<SafeAreaPage> createState() => _SafeAreaPageState();
}

class _SafeAreaPageState extends State<SafeAreaPage> {
  bool top = true;
  bool bottom = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          top: top,
          left: true,
          bottom: bottom,
          right: true,
          minimum: const EdgeInsets.all(1.0),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This is an example explaining use of SafeArea.',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                  Text(
                    'This is an example explaining use of SafeArea.',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ]),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('SafeArea: top'),
                      Switch(
                          value: top,
                          onChanged: (bool value) {
                            setState(() {
                              top = value;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('SafeArea: bottom'),
                      Switch(
                          value: bottom,
                          onChanged: (bool value) {
                            setState(() {
                              bottom = value;
                            });
                          }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('top: ${MediaQuery.of(context).padding.top}'),
                      Text('bottom: ${MediaQuery.of(context).padding.bottom}'),
                      Text('width: ${MediaQuery.of(context).size.width}'),
                      Text('height: ${MediaQuery.of(context).size.height}'),
                    ],
                  ),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}
