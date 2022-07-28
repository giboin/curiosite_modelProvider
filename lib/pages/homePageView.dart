import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class HomePageView extends StatefulWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child:Column(
      children: [
        TextField(),
        Row(
          children: [
            IconButton(
                onPressed: (){

            },
                icon: const Icon(Icons.home)
            )
          ],
        )
      ],
      )
    );
  }

}
