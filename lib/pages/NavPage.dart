import 'package:curiosite/TabView.dart';
import 'package:curiosite/pages/favoritesPage.dart';
import 'package:curiosite/pages/settingsPage.dart';
import 'package:curiosite/pages/tabsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../model/modelProvider.dart';
import 'historyPage.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {


  TabView get currentTab => ModelProvider.of(context).tabs[ModelProvider.of(context).currentTabIndex];
  get pcVersionIcon => currentTab.pcVersion?const Icon(Icons.check_box_rounded, color: Colors.black,):const Icon(Icons.check_box_outline_blank, color: Colors.black,);

  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState((){}));
    initModel();

    ModelProvider.of(context).searchBarFocusNode.addListener(() {
      if(!ModelProvider.of(context).searchBarFocusNode.hasFocus){
        ModelProvider.of(context).searchBarTextController.text=ModelProvider.of(context).formatUrlForText(currentTab.url);
      }
      else{
        ModelProvider.of(context).searchBarTextController.selection=TextSelection.collapsed(offset: ModelProvider.of(context).searchBarTextController.text.length);
      }
    });
    super.didChangeDependencies();
  }

  void initModel()async{
    ModelProvider.of(context).init();
    await ModelProvider.of(context).loadTabs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(ModelProvider.of(context).tabs.isEmpty){
      return const Center(child:Text(""));
    }
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
          if(currentTab.webOExplorerI.value==0) {
            if (await currentTab.webController.canGoBack()) {
              currentTab.webController.goBack();
              return false;
            }
          }else{
            if(await currentTab.explorerController.canGoBack()){
              currentTab.explorerController.goBack();
              ModelProvider.of(context).searchBarTextController.text=currentTab.explorerController.parentPath;
              setState(() {});
              return false;
            }
          }
          return true;
        },
        child:Scaffold(
            appBar: appBar(context),
            body: IndexedStack(
              index: ModelProvider.of(context).currentTabIndex,
              children: ModelProvider.of(context).tabs.map((webViewTab) {
                return webViewTab;
              }).toList(),)
        )
    );
  }



  PreferredSizeWidget appBar(BuildContext context){
    if(!ModelProvider.of(context).searchMode){
      return AppBar(
          backgroundColor: currentTab.incognito?Colors.grey[800]:Colors.blue,
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
      backgroundColor: currentTab.incognito?Colors.grey[800]:Colors.blue,
      title: ValueListenableBuilder<String>(
          valueListenable: ModelProvider.of(context).foundMatches,
          builder: (context, value, _) {
            return TextField(

              decoration: InputDecoration(suffixText: ModelProvider.of(context).foundMatches.value),
              onChanged: (string){
                currentTab.webController.findAllAsync(find: string);

              },
            );}),
      actions: [
        IconButton(
            onPressed: (){
              currentTab.webController.findNext(forward: false);
            },
            icon: const Icon(Icons.keyboard_arrow_up_rounded)
        ),
        IconButton(
            onPressed: (){
              currentTab.webController.findNext(forward: true);
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
      keyboardType: TextInputType.url,
      controller: ModelProvider.of(context).searchBarTextController,
      focusNode: ModelProvider.of(context).searchBarFocusNode,
      onSubmitted: (text){
        ModelProvider.of(context).search(text.trim());
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              ModelProvider.of(context).searchBarTextController.text="";
              ModelProvider.of(context).searchBarFocusNode.requestFocus();
            },
          ),
          prefixIcon: ValueListenableBuilder<bool>(
              valueListenable:ModelProvider.of(context).isSecure,
              builder: (context, value, _) {
                return ModelProvider.of(context).isSecure.value?const Icon(Icons.lock, color:Colors.green,):const Icon(Icons.lock_open, color: Colors.black,);
              }
          ),
          hintText: 'Search...',
          border: InputBorder.none
      ),
    );
  }



  Widget appbarMenu(BuildContext context){
    return PopupMenuButton(
        onSelected: (result) async {
          switch(result){
            case 1:
              ModelProvider.of(context).newTab();
              setState(() {
                ModelProvider.of(context).currentTabIndex=ModelProvider.of(context).tabs.length-1;
              });
              ModelProvider.of(context).saveTabs();
              break;
            case 2:
              ModelProvider.of(context).newTab(incognito: true);
              setState(() {
                ModelProvider.of(context).currentTabIndex=ModelProvider.of(context).tabs.length-1;
              });
              ModelProvider.of(context).saveTabs();
              break;
            case 3: _openHistory(context); break;
            case 4: _openFavorites(context); break;
            case 5: _openSearchMode(); break;
            case 7: await _openSettings(context); break;
            case 8: _changeMode(context);break;
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
                        currentTab.webController.goForward();
                      }
                  ),
                  MaterialButton(
                      child:const Icon(Icons.refresh),
                      onPressed: (){
                        currentTab.webController.reload();
                        Navigator.pop(context);
                      }
                  ),
                  MaterialButton(

                      child:ValueListenableBuilder<bool>(
                          valueListenable:ModelProvider.of(context).isFav,
                          builder: (context, value, _) {return Icon(ModelProvider.of(context).isFav.value?Icons.star:Icons.star_border);}),
                      onPressed: ()async{
                        String title = await currentTab.webController.getTitle()??"";
                        String url = (await currentTab.webController.getUrl()).toString();
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
                  const Icon(Icons.plus_one, color: Colors.lightGreen,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Nouvel onglet")
                ],
              )
          ),
          PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  //const Icon(Icons.add_moderator, color: Colors.black,),
                  const ImageIcon(AssetImage("lib/assets/incognito.png"), color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Nouvel onglet nav. priv.")
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
                  const Icon(Icons.star, color: Colors.yellow,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Favoris")
                ],
              )
          ),
          PopupMenuItem(
              value: 5,
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.blue,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Rechercher sur la page")
                ],
              )
          ),
          PopupMenuItem(
              value:6,
              onTap: (){
                currentTab.pcVersion=!currentTab.pcVersion;
                currentTab.webController.setOptions(options: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        preferredContentMode: currentTab.pcVersion? UserPreferredContentMode.DESKTOP : UserPreferredContentMode.MOBILE
                    )
                ),);
                currentTab.webController.reload();
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
                const Icon(Icons.settings, color: Colors.grey,),
                Container(margin: const EdgeInsets.only(right: 20),),
                const Text("Paramètres")
              ],
            ),
          ),
          const PopupMenuItem(
              value:8,
              child: Card(
                child: ListTile(
                    title:Text("change mode")
                ),
              )
          )
        ]

    );
  }

  Future<void> _changeMode(BuildContext ctx) async {
    if(currentTab.webOExplorerI.value==0){
      currentTab.webOExplorerI.value=1;
      ModelProvider.of(context).searchBarTextController.text=currentTab.explorerController.currentPath;
      setState(() {});
    }else{
      currentTab.webOExplorerI.value=0;
      ModelProvider.of(context).searchBarTextController.text=currentTab.url;
    }
  }

  Future<void> _openSettings(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  Future<void> _openHistory(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => const HistoryPage())).then((value) {
      if(value!=null){
        currentTab.webController.loadUrl(urlRequest: URLRequest(url: Uri.parse(value[0])));
      }
    });
  }

  Future<void> _openFavorites(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => const FavoritesPage())).then((value){
      if(value!=null){
        currentTab.webController.loadUrl(urlRequest: URLRequest(url: Uri.parse(value[0])));
      }
      setState(() {
        ModelProvider.of(context).isFavUpdate();
      });
    });
  }

  Future<void> _openTabs(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => const TabsPage())).then((value){
      setState(() {
        ModelProvider.of(context).changeBarText(currentTab.webOExplorerI.value==0
            ? ModelProvider.of(context).formatUrlForText(currentTab.url)
            : currentTab.explorerController.currentPath);
        ModelProvider.of(context).isFavUpdate();
        ModelProvider.of(context).isSecureUpdate();
        ModelProvider.of(context).saveTabs();
      });
    });
  }

  void _openSearchMode(){
    setState(() {
      ModelProvider.of(context).searchMode=true;
    });
  }


}
