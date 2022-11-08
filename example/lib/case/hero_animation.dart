import 'package:flutter/material.dart';
import 'details.dart';

class HeroAnimation extends StatefulWidget {
  const HeroAnimation({Key? key}) : super(key: key);

  @override
  State<HeroAnimation> createState() => _HeroAnimationState();
}

class _HeroAnimationState extends State<HeroAnimation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Wrap(
          spacing: 18.0, // gap between adjacent chips
          runSpacing: 14.0, // gap between lines
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Hero Animation',
                style: TextStyle(
                  fontFamily: 'Allison',
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      // To solve the issue that anonymous routes cannot receive
                      // lifecycle callbacks, add route names as identifiers in
                      // |RouteSetting|.
                      //
                      // See https://github.com/alibaba/flutter_boost/pull/1196
                      // for details.
                      settings: const RouteSettings(name: '/hero_details'),
                      builder: (context) => const DetailsPage())),
              child: Hero(
                tag: 'blabala',
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: 100,
                  height: 100,
                  child: Image.asset('images/keep_green_code.jpg'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
