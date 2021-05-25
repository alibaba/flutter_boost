import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';

class Model {
  Model(this.title, this.onTap);

  String title;
  VoidCallback onTap;
}

class MainPage extends StatefulWidget {
  final String data;

  const MainPage({Key key, this.data}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ///
    ///Focus on code below to know the basic API
    ///大家重点关注这个Model里面各个API的调用，其他的都是UI的布局可以不用看
    ///
    List<Model> models = [
      Model("open native page", () {
        BoostNavigator.instance.push("homePage", arguments: {
          'data': _controller.text
        }).then((value) => showTipIfNeeded(value.toString()));
      }),
      Model("return to native page with data", () {
        Map<String, Object> result = {'data': _controller.text};
        BoostNavigator.instance.pop(result);
      }),
      Model("open flutter page with container", () {
        BoostNavigator.instance.push("simplePage",
            withContainer: true,
            arguments: {
              'data': _controller.text
            }).then((value) => showTipIfNeeded(value.toString()));
      }),
      Model("open flutter page without container", () {
        BoostNavigator.instance.push("simplePage",
            withContainer: false,
            arguments: {
              'data': _controller.text
            }).then((value) => showTipIfNeeded(value.toString()));
      }),
      Model("open lifecycle test page", () {
        BoostNavigator.instance.push(
          "lifecyclePage",
          withContainer: false,
        );
      }),
      Model("open dialog without container", () {
        BoostNavigator.instance.push(
          "dialogPage",
          withContainer: false,

          ///如果不需要开启新容器的情况下可以不用管opaque参数
        );
      }),
      Model("open dialog with container", () {
        BoostNavigator.instance.push("dialogPage",
            withContainer: true,

            ///如果开启新容器，需要指定opaque为false
            opaque: false);
      }),
    ];

    ///You don't need to take care about the code below
    ///你不需要关心下面的UI代码
    ///==========================================================

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              BoostNavigator.instance.pop();
            },
          ),
          middle: Text('FlutterBoost Example'),
        ),
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            emptyBox(0, 20),
            _buildHeader(),
            emptyBox(0, 30),
            SliverToBoxAdapter(
                child: Center(
              child: Text('Data String is: ${widget.data}',
                  style: TextStyle(fontSize: 30)),
            )),
            emptyBox(0, 30),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (ctx, index) => item(models[index]),
                    childCount: models.length)),
          ],
        ),
      ),
    );
  }

  Widget emptyBox(double width, double height) {
    return SliverToBoxAdapter(
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoTextField(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          controller: _controller,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Colors.amber),
          placeholder: 'input data ',
          placeholderStyle: TextStyle(color: Colors.black38),
        ),
      ),
    );
  }

  Widget item(Model model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 15),
        onPressed: model.onTap,
        child: Text(model.title,
            style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  void showTipIfNeeded(String value) {
    if (value == null || value == 'null' || value.isEmpty) {
      return;
    }
    final bar = SnackBar(
        content: Text('return value is $value'),
        duration: const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }
}
