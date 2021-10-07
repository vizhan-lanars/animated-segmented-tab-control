import 'package:customizable_tab_bar/customizable_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomizableTabBar(
                    backgroundColor: Colors.indigoAccent,
                    indicatorColor: Colors.indigo,
                    tabTextColor: Colors.white.withOpacity(0.5),
                    selectedTabTextColor: Colors.white,
                    squeezeIntensity: 2,
                    height: 30,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: Theme.of(context).textTheme.caption,
                    tabs: [
                      CustomizableTab(
                        // flex: 2,
                        label: 'ACCOUNT',
                        backgroundColor: Colors.blueGrey,
                        color: Colors.blueGrey.shade200,
                      ),
                      CustomizableTab(
                        flex: 2,
                        label: 'HOME',
                        backgroundColor: Colors.grey.shade100,
                        color: Colors.white,
                        selectedTextColor: Colors.black,
                        textColor: Colors.black.withOpacity(0.5),
                      ),
                      const CustomizableTab(
                        // flex: 3,
                        label: 'NEW',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Container(
                        alignment: Alignment.center,
                        color: Colors.blueGrey.withOpacity(0.5),
                        child: const Text('1'),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: const Text('2'),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: Colors.blue.withOpacity(0.5),
                        child: const Text('3'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
