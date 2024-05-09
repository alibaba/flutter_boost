import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(RunMyApp());

class RunMyApp extends StatelessWidget {
  RunMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Copy to Clipboard'),
        ),
        body: ClipboardExample(),
      ),
    );
  }
}

class ClipboardExample extends StatelessWidget {
  ClipboardExample({super.key});
  // controller to retrieve the text
  TextEditingController copy_controller = TextEditingController();
  TextEditingController paste_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Copy to Clipboard'),
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: copy_controller,
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(
                          new ClipboardData(text: copy_controller.text))
                      .then((_) {
                    copy_controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied to your clipboard !')));
                  });
                },
                child: const Text('Copy'),
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: paste_controller,
                decoration: const InputDecoration(
                  labelText: 'Pasted text will appear here',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Clipboard.getData('text/plain').then((value) {
                    paste_controller.text = value!.text!;
                  });
                },
                child: const Text('Paste'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
