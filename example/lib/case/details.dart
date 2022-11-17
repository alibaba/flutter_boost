import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details page'),
      ),
      body: Center(
        child: Hero(
            tag: 'blabala',
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 350,
                  height: 350,
                  child: Image.asset('images/keep_green_code.jpg'),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      text: 'COVID-19 ...',
                      style: const TextStyle(
                        fontSize: 30.0,
                        color: Colors.blue,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Get out of here! ...'
                              'Get out of here! Get out of here!'
                              ' Get out of here! Get out of here! ...',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: '\n\n[Go back]',
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.green,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
