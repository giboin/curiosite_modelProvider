import 'dart:typed_data';

import 'package:curiosite/TabView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../model/modelProvider.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({Key? key}) : super(key: key);

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {

  List<TabView> get tabs => ModelProvider.of(context).tabs;
  int get currentTabIndex => ModelProvider.of(context).currentTabIndex;
  Uint8List transparent = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 67, 0, 0, 0, 67, 8, 6, 0, 0, 0, 199, 202, 184, 115, 0, 0, 0, 1, 115, 82, 71, 66, 0, 174, 206, 28, 233, 0, 0, 0, 4, 103, 65, 77, 65, 0, 0, 177, 143, 11, 252, 97, 5, 0, 0, 0, 9, 112, 72, 89, 115, 0, 0, 14, 192, 0, 0, 14, 192, 1, 106, 214, 137, 9, 0, 0, 0, 40, 73, 68, 65, 84, 120, 94, 237, 193, 1, 13, 0, 0, 0, 194, 160, 247, 79, 109, 15, 7, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 192, 175, 26, 70, 103, 0, 1, 162, 219, 130, 18, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
  Uint8List blanc = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 67, 0, 0, 0, 67, 4, 3, 0, 0, 0, 53, 228, 165, 64, 0, 0, 0, 1, 115, 82, 71, 66, 0, 174, 206, 28, 233, 0, 0, 0, 4, 103, 65, 77, 65, 0, 0, 177, 143, 11, 252, 97, 5, 0, 0, 0, 3, 80, 76, 84, 69, 255, 255, 255, 167, 196, 27, 200, 0, 0, 0, 9, 112, 72, 89, 115, 0, 0, 14, 192, 0, 0, 14, 192, 1, 106, 214, 137, 9, 0, 0, 0, 25, 73, 68, 65, 84, 72, 199, 237, 193, 129, 0, 0, 0, 0, 195, 160, 249, 83, 95, 224, 8, 85, 0, 0, 60, 53, 9, 41, 0, 1, 189, 16, 0, 237, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);

  set tabs(List<TabView> list) {
    ModelProvider.of(context).saveTabs(list: list);
  }

  set currentTabIndex(int index){
    ModelProvider.of(context).currentTabIndex=index;
  }


  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState(() {}));
    super.didChangeDependencies();
  }

  /*void test() async{
    ByteData bytes = await rootBundle.load('lib/assets/transparent.png');
    Uint8List list = bytes.buffer.asUint8List();
    print("====>"+list.toString());
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Onglets"),
        actions: [
          IconButton(
              onPressed:(){
                Navigator.pop(context);
                ModelProvider.of(context).newTab();
                currentTabIndex=tabs.length-1;
                ModelProvider.of(context).saveTabs();
              },
              icon: const Icon(Icons.add)
          ),
          PopupMenuButton(
            onSelected: (result) async {
              switch(result){
                case 1: showDialog(context: context, builder: (ctx) {
                  return AlertDialog(
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            ModelProvider.of(context).tabs.clear();
                            ModelProvider.of(context).newTab();
                            currentTabIndex=0;
                            ModelProvider.of(context).saveTabs();
                          },
                          child: const Text("Oui")
                      ),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text("Non")
                      )
                    ],
                    title: const Text("supprimer les onglets"),
                    content: const Text(
                        "Voulez vous vraiment supprimer tout les onglets?"),
                  ); });break;
                case 2:{
                  Navigator.pop(context);
                  ModelProvider.of(context).newTab(incognito: true);
                  ModelProvider.of(context).currentTabIndex=tabs.length-1;
                  ModelProvider.of(context).saveTabs();
                }break;
              }
            },

            itemBuilder: (context)=>[
              const PopupMenuItem(
                  value:1,
                  child:Text("fermer tout")
              ),
              const PopupMenuItem(
                  value:2,
                  child:Text("Nouvel onglet nav. privée")
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
            GridView.count(
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              children: List.generate(tabs.length, (index) {
                return GestureDetector(
                  child:Container(
                      margin:const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius:BorderRadius.circular(10),
                        color: tabs[index].incognito?Colors.grey[800]:Colors.blue,
                      ),
                      child:Column(
                        children: [
                          AspectRatio(
                              aspectRatio: 5,
                              child:Row(children: [
                                FutureBuilder(
                                    future:tabs[index].webController.getFavicons(),
                                    builder: (BuildContext buildContext, AsyncSnapshot<List<Favicon>?> snapshot){
                                      if(snapshot.data?.first==null){
                                        return  Container(
                                            margin: const EdgeInsets.all(5),
                                            child:Image.memory(transparent)
                                        );
                                      }
                                      print("==>"+tabs[index].url);
                                      print("==>favicon: "+(snapshot.data?.first.url.toString()??""));
                                      Widget favicon=Image.network(snapshot.data?.first.url.toString()??"",
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return  Image.asset('lib/assets/broken fav.png');
                                        },);
                                      print(favicon.toString());
                                      return  Container(
                                          margin: const EdgeInsets.all(5),
                                          child:ClipRRect(
                                              borderRadius: BorderRadius.circular(5),
                                              child:favicon
                                          )
                                      );
                                    }
                                ),
                                FutureBuilder(
                                    future:tabs[index].webController.getTitle(),
                                    builder: (BuildContext buildContext, AsyncSnapshot<String?> snapshot){
                                      return Expanded(child:Text(snapshot.data??"", style: const TextStyle(color: Colors.white),));
                                    }
                                ),
                                IconButton(
                                    onPressed: (){
                                      //test();
                                      setState(() {
                                        if(tabs.length>1) {
                                          ModelProvider.of(context).removeTab(index);
                                        }else{
                                          ModelProvider.of(context).search(ModelProvider.of(context).home);
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.clear, color: Colors.white,)
                                )
                              ],)
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 5,right: 5),
                              child: FutureBuilder(
                                  future:tabs[index].webController.takeScreenshot(),
                                  builder: (BuildContext buildContext, AsyncSnapshot<Uint8List?> snapshot){
                                    return AspectRatio(
                                        aspectRatio: 0.75,
                                        child:ClipRRect(
                                            borderRadius:BorderRadius.circular(10),
                                            child:Image.memory(
                                              snapshot.data??blanc,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,

                                            )
                                        )
                                    );
                                  }
                              )
                          ),
                        ],
                      )

                  ),
                  onTap: (){
                    setState(() {
                      ModelProvider.of(context).currentTabIndex=index;
                      ModelProvider.of(context).saveTabs();
                    });
                    Navigator.pop(context);
                  },
                );
              }
              ),
            ),
          )
        ],
      ),
    );
  }

}