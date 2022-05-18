import 'package:curiosite/TabWebView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/modelProvider.dart';

class TabsPage extends StatefulWidget {
  TabsPage({Key? key}) : super(key: key);

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {

  List<TabWebView> get tabs => ModelProvider.of(context).tabs;

  set tabs(List<TabWebView> list) {
    ModelProvider.of(context).saveTabs(list: list);
  }


  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState(() {}));
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tabs"),
        actions: [
          IconButton(
              onPressed:(){
                setState(() {
                  ModelProvider.of(context).newTab();
                });
              },
              icon: const Icon(Icons.add)
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              showDialog(context: context, builder: (ctx) {
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ModelProvider.of(context).tabs.clear();
                            ModelProvider.of(context).newTab(url:"flutter.dev");
                            ModelProvider.of(context).currentTabIndex=0;
                          });
                          Navigator.pop(ctx);
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
                );
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    TabWebView tab=tabs[index];
                    String url = tab.url;
                    return ListTile(
                      leading: Icon(index==ModelProvider.of(context).currentTabIndex?Icons.arrow_forward_sharp:null),
                      title: SizedBox(
                          height: 25,
                          child: Text(url, overflow: TextOverflow.fade,
                            softWrap: false,)
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (selectedValue) {
                          switch (selectedValue) {
                            case 1:
                            //supprimer
                              setState(() {
                              ModelProvider.of(context).removeTab(index);
                              });
                              break;
                            case 2:
                            //copy to cliboard
                              Clipboard.setData(ClipboardData(text: url));

                              break;
                            default:
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              child: Text("supprimer"), value: 1,),
                            const PopupMenuItem(
                                child: Text("copier le lien"), value: 2)
                          ];
                        },
                      ),
                      onTap: () {
                        setState(() {
                          ModelProvider.of(context).currentTabIndex=index;
                        });
                        Navigator.pop(context);
                      },
                    );

                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 3, color: Colors.grey);
                  },
                  itemCount: tabs.length
              )
          )
        ],
      ),
    );
  }

}