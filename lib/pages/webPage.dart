import 'package:curiosite/TabWebView.dart';
import 'package:curiosite/pages/favoritesPage.dart';
import 'package:curiosite/pages/settingsPage.dart';
import 'package:curiosite/pages/tabsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../model/modelProvider.dart';
import 'historyPage.dart';

class WebPage extends StatefulWidget {
  WebPage({Key? key}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {


  TabWebView get currentTab => ModelProvider.of(context).tabs[ModelProvider.of(context).currentTabIndex.value];
  get pcVersionIcon => currentTab.pcVersion?const Icon(Icons.check_box_rounded, color: Colors.black,):const Icon(Icons.check_box_outline_blank, color: Colors.black,);

  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState((){}));
    ModelProvider.of(context).init();
    ModelProvider.of(context).searchBarFocusNode.addListener(() {
      if(!ModelProvider.of(context).searchBarFocusNode.hasFocus){
        ModelProvider.of(context).searchBarTextController.text=currentTab.url;
      }
      else{
        ModelProvider.of(context).searchBarTextController.selection=TextSelection.collapsed(offset: ModelProvider.of(context).searchBarTextController.text.length);
      }
    });
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if(ModelProvider.of(context).searchMode){
            setState(() {
              ModelProvider.of(context).clearFindWorld();
            });
            return false;
          }
          if(ModelProvider.of(context).searchBarFocusNode.hasFocus){
            ModelProvider.of(context).searchBarFocusNode.unfocus();
            return false;
          }
          if (await currentTab.controller.canGoBack()){
            currentTab.controller.goBack();
            return false;
          }
          return true;
        },
        child:Scaffold(
            appBar: appBar(context),
            body: ValueListenableBuilder(
              valueListenable: ModelProvider.of(context).currentTabIndex,
              builder: (context, value, _){
                return IndexedStack(
                  index:ModelProvider.of(context).currentTabIndex.value,
                  children: ModelProvider.of(context).tabs,
                );
              },
            )
        )
    );
  }



  PreferredSizeWidget appBar(BuildContext context){
    if(!ModelProvider.of(context).searchMode){
      return AppBar(
          title: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),

            child: Center(
              child: searchBar(),
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: ((){
                _openTabs(context);
              }),
              child: Center(
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white, width: 2.5)
                  ),
                  child:Center(
                      child:Text(ModelProvider.of(context).tabs.length.toString())
                  ),
                ),
              ),
            ),
            appbarMenu(context),
          ]
      );
    }
    return AppBar(
      title: ValueListenableBuilder<String>(
          valueListenable: ModelProvider.of(context).foundMatches,
          builder: (context, value, _) {
            return TextField(

              decoration: InputDecoration(suffixText: ModelProvider.of(context).foundMatches.value),
              onChanged: (string){
                currentTab.controller.findAllAsync(find: string);

              },
            );}),
      actions: [
        IconButton(
            onPressed: (){
              currentTab.controller.findNext(forward: false);
            },
            icon: const Icon(Icons.keyboard_arrow_up_rounded)
        ),
        IconButton(
            onPressed: (){
              currentTab.controller.findNext(forward: true);
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded)
        ),
        IconButton(onPressed: (){
          setState(() {
            ModelProvider.of(context).clearFindWorld();
          });
        }, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget searchBar(){
    return TextField(
      controller: ModelProvider.of(context).searchBarTextController,
      focusNode: ModelProvider.of(context).searchBarFocusNode,
      keyboardType: TextInputType.url,
      onSubmitted: (text){
        ModelProvider.of(context).search(text);
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              ModelProvider.of(context).searchBarTextController.text="";
              ModelProvider.of(context).searchBarFocusNode.requestFocus();
            },
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ModelProvider.of(context).search(ModelProvider.of(context).searchBarTextController.text);
            },
          ),
          hintText: 'Search...',
          border: InputBorder.none),
    );
  }



  Widget appbarMenu(BuildContext context){
    return PopupMenuButton(
        onSelected: (result) async {
          switch(result){
            case 3: _openHistory(context); break;
            case 4: _openFavorites(context); break;
            case 5: _openSearchMode(); break;
            case 7: await _openSettings(context); break;
          }
        },
        itemBuilder: (context)=>[
          PopupMenuItem(
              value:0,
              child: Row(
                children: [
                  ElevatedButton(
                      child:const Icon(Icons.arrow_forward),
                      onPressed: (){
                        currentTab.controller.goForward();
                      }
                  ),
                  MaterialButton(
                      child:const Icon(Icons.refresh),
                      onPressed: (){
                        currentTab.controller.reload();
                        Navigator.pop(context);
                      }
                  ),
                  MaterialButton(

                      child:ValueListenableBuilder<bool>(
                          valueListenable:ModelProvider.of(context).isFav,
                          builder: (context, value, _) {return Icon(ModelProvider.of(context).isFav.value?Icons.star:Icons.star_border);}),
                      onPressed: ()async{
                        String title = await currentTab.controller.getTitle()??"";
                        String url = (await currentTab.controller.getUrl()).toString();
                        Navigator.pop(context);
                        for(String str in ModelProvider.of(context).favorites) {
                          if (str.contains("\n$url.")) {
                            setState(() {
                              ModelProvider.of(context).isFav.value = false;
                              ModelProvider.of(context).favorites.remove(str);
                              ModelProvider.of(context).saveFavorites(ModelProvider.of(context).favorites);
                            });
                            return;
                          }
                        }
                        showBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController titleController = TextEditingController();
                              titleController.text = title;
                              TextEditingController urlController = TextEditingController();
                              urlController.text = url;
                              return SingleChildScrollView(
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 30),
                                      child: Column(
                                        children: [
                                          const Text("Ajouter un favori",
                                            style: TextStyle(
                                                fontSize: 20),),
                                          const Divider(height: 5,
                                              color: Colors.white),
                                          const Divider(height: 3,
                                              color: Colors.grey),
                                          const Divider(height: 5,
                                              color: Colors.white),
                                          Container(
                                              alignment: Alignment.topLeft,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 20, 0, 0),
                                              child: const Text("titre:")
                                          ),
                                          TextField(
                                            decoration: const InputDecoration(
                                              hintText: "nom du favoris",),
                                            controller: titleController,
                                          ),
                                          Container(
                                              alignment: Alignment.topLeft,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 20, 0, 0),
                                              child: const Text("url:")
                                          ),
                                          TextField(
                                            decoration: const InputDecoration(
                                              hintText: "url du favoris",),
                                            controller: urlController,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(child: Container()),
                                              Container(
                                                margin: const EdgeInsets
                                                    .fromLTRB(
                                                    10, 10, 10, 0),
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      ModelProvider.of(context).isFav.value = true;
                                                      ModelProvider.of(context).favorites.add("${titleController.text}\n${urlController.text}.");
                                                      ModelProvider.of(context).saveFavorites(ModelProvider.of(context).favorites);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Ok")
                                                ),
                                              ),
                                              Container(
                                                  margin: const EdgeInsets
                                                      .fromLTRB(
                                                      10, 10, 10, 0),
                                                  child: OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context);
                                                      },
                                                      child: const Text(
                                                          "Annuler")
                                                  )
                                              )
                                            ],
                                          )
                                        ],

                                      )
                                  )
                              );
                            }
                        );

                      }
                  ),
                ],
              )
          ),
          PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  const Icon(Icons.add_moderator, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Nouvel onglet nav. priv.")
                ],
              )
          ),
          PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  const Icon(Icons.file_open, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Nouvel onglet expl. fichiers")
                ],
              )
          ),
          PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Historique")
                ],
              )
          ),
          PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Favoris")
                ],
              )
          ),
          PopupMenuItem(
              value: 5,
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Rechercher sur la page")
                ],
              )
          ),
          PopupMenuItem(
              value:6,
              onTap: (){
                currentTab.pcVersion=!currentTab.pcVersion;
                currentTab.controller.setOptions(options: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        preferredContentMode: currentTab.pcVersion? UserPreferredContentMode.DESKTOP : UserPreferredContentMode.MOBILE
                    )
                ),);
                currentTab.controller.reload();
              },
              child: Row(
                children: [
                  const Icon(Icons.computer, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Version pour ordi"),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  pcVersionIcon,
                ],
              )
          ),
          PopupMenuItem(
            value: 7,
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.black,),
                Container(margin: const EdgeInsets.only(right: 20),),
                const Text("Paramètres")
              ],
            ),
          ),
        ]

    );
  }


  Future<void> _openSettings(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  Future<void> _openHistory(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => const HistoryPage())).then((value) {
      if(value!=null){
        currentTab.controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(value[0])));
      }
    });
  }

  Future<void> _openFavorites(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => FavoritesPage())).then((value){
      if(value!=null){
        currentTab.controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(value[0])));
      }
      setState(() {
        ModelProvider.of(context).isFavUpdate();
      });
    });
  }

  Future<void> _openTabs(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => TabsPage())).then((value){
      setState(() {
        ModelProvider.of(context).searchBarTextController.text=ModelProvider.of(context).tabs[ModelProvider.of(context).currentTabIndex.value].url;
      });
    });
  }

  void _openSearchMode(){
    setState(() {
      ModelProvider.of(context).searchMode=true;
    });
  }


}
