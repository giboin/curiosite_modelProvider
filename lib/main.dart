
import 'dart:async';
import 'package:curiosite/assets/favoris.dart';
import 'package:curiosite/historique.dart';
import 'package:curiosite/parametres.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Curiosite',
    theme: ThemeData(primarySwatch: Colors.blue,),
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => const MyApp(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/param': (context) => Parametres(),
      '/histo':(context) => Historique(),
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late InAppWebViewController _webViewController;
  String url = "";
  double progress = 0;
  bool pcVersion =  UserPreferredContentMode.RECOMMENDED==UserPreferredContentMode.DESKTOP;
  bool searchMode=false;
  TextEditingController searchBarTextController = TextEditingController();
  FocusNode searchBarFocusNode = FocusNode();
  String _foundMatches="0/0";
  List<String> historique= [];
  List<String> _favoris=[];
  String searchEngine='google';
  Icon starIcon = const Icon(Icons.star_border);

  get pcVersionIcon => pcVersion?const Icon(Icons.check_box_rounded, color: Colors.black,):const Icon(Icons.check_box_outline_blank, color: Colors.black,);

  Future<void> _getEngine() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('engine')) {
      return;
    }
    setState(() {
      searchEngine = prefs.getString('engine') ?? "erreur";
    });
  }

  Future<void> _getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('history')) {
      return;
    }
    setState(() {
      historique = prefs.getStringList('history') ?? ["erreur"];
    });
  }

  Future<void> _saveHistory(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', list);
    historique=list;
  }

  Future<void> _getFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('favoris')) {
      return;
    }
    setState(() {
      _favoris = prefs.getStringList('favoris') ?? ["erreur"];
    });
  }

  Future<void> _saveFavoris(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoris', list);
    _favoris=list;
  }

  @override
  void initState() {
    super.initState();
    _getEngine();
    _getHistory();
    _getFavoris();
    searchBarFocusNode.addListener(() {
      if(!searchBarFocusNode.hasFocus){
        searchBarTextController.text=url;
      }
    });
  }

  @override
  void dispose() {
    searchBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    searchBarTextController.text=url;
    return WillPopScope(
        onWillPop: () async {
          if(searchMode){
            setState(() {
              clearFindWorld();
            });
            return false;
          }
          if (await _webViewController.canGoBack()){
            _webViewController.goBack();
            return false;
          }
          return true;
        },
        child: Builder(builder:(context)=>Scaffold(
          appBar: appBar(context),
          body: Column(children: <Widget>[
            Container(
                child: progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container()),
            Expanded(
              child: InAppWebView(
                onLoadStart:(_webViewController, uri){
                  setState(() {
                    //url = uri.toString();
                  });
                },
                onFindResultReceived: (controller, activeMatchOrdinal, numberOfMatches, isDoneCounting) {
                  if (isDoneCounting) {
                    setState(() {
                      _foundMatches = numberOfMatches>0?(activeMatchOrdinal+1).toString() + "/" +
                          numberOfMatches.toString():"0/0";
                    });
                  }
                },
                initialUrlRequest: URLRequest(url:Uri(path: "flutter.dev/")),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  var title = await _webViewController.getTitle();
                  var date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
                  setState(() {
                    this.url = url.toString();
                    starIcon=const Icon(Icons.star_border);
                    for(String str in _favoris){
                      if(str.substring(str.indexOf("\n"),str.length)==(url.toString())){
                        starIcon=const Icon(Icons.star);
                      }
                    }
                  });
                  await _getHistory();
                  historique.add("$date$title\n$url");
                  _saveHistory(historique);
                },
                onProgressChanged: (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
              ),
            ),
          ]),
        ),
        )

    );
  }

  Widget appbarMenu(BuildContext context){
    return PopupMenuButton(
        onSelected: (result) async {
          switch(result){
            case 3: _openHistory(context); break;
            case 4: _openFavoris(context); break;
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
                        _webViewController.goForward();
                      }
                  ),
                  MaterialButton(
                      child:const Icon(Icons.refresh),
                      onPressed: (){
                        _webViewController.reload();
                      }
                  ),
                  MaterialButton(
                      key: UniqueKey(),
                      child:starIcon,
                      onPressed: ()async{
                        var title = await _webViewController.getTitle();
                        var url = (await _webViewController.getUrl()).toString();
                        Navigator.pop(context);
                        if(_favoris.contains("$title\n$url")) {
                          setState(() {
                            starIcon = const Icon(Icons.star_border);
                            _favoris.remove("$title\n$url");
                          });
                          _saveFavoris(_favoris);
                        }
                        else {
                          showBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController titleController = TextEditingController();
                                titleController.text = title ?? "";
                                TextEditingController urlController = TextEditingController();
                                urlController.text = url ;
                                return SingleChildScrollView(
                                    child:Container(
                                        margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                                        child: Column(
                                          children: [
                                            const Text("Ajouter un favori", style: TextStyle(fontSize:20),),
                                            const Divider(height: 5, color: Colors.white),
                                            const Divider(height: 3, color: Colors.grey),
                                            const Divider(height: 5, color: Colors.white),
                                            Container(
                                                alignment: Alignment.topLeft,
                                                margin:EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                child:const Text("titre:")
                                            ),
                                            TextField(
                                              decoration: const InputDecoration(
                                                hintText: "nom du favoris",),
                                              controller: titleController,
                                            ),
                                            Container(
                                                alignment: Alignment.topLeft,
                                                margin:EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                child:const Text("url:")
                                            ),
                                            TextField(
                                              decoration: const InputDecoration(
                                                hintText: "url du favoris",),
                                              controller: urlController,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(child:Container()),
                                                Container(
                                                  margin:const EdgeInsets.fromLTRB(10,10,10,0),
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          starIcon = const Icon(Icons.star);
                                                          _favoris.add("$title\n$url");
                                                        });
                                                        _saveFavoris(_favoris);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Ok")
                                                  ),
                                                ),
                                                Container(
                                                    margin:const EdgeInsets.fromLTRB(10,10,10,0),
                                                    child:OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("Annuler")
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
                pcVersion=!pcVersion;
                _webViewController.setOptions(options: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        preferredContentMode: pcVersion? UserPreferredContentMode.DESKTOP : UserPreferredContentMode.MOBILE
                    )
                ),);
                _webViewController.reload();
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
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => Parametres())).then((value) => _getEngine());
  }

  Future<void> _openHistory(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => Historique())).then((value) =>{
      _getHistory(),
      if(value!=null) {
        setState(() {
          _webViewController.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(value[0])));
        })
      }
    });
  }

  Future<void> _openFavoris(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (context) => Favoris())).then((value) =>{
      _getFavoris(),
      setState(() {
        starIcon=const Icon(Icons.star_border);
        for(String str in _favoris){
          if(str.substring(str.indexOf("\n"),str.length)==(url.toString())){
            starIcon=const Icon(Icons.star);
          }
        }
        if(value!=null) {
          _webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(value[0])));
        }
      })
    });
  }

  void _openSearchMode(){
    setState(() {
      searchMode=true;
    });
  }


  PreferredSizeWidget appBar(BuildContext context){
    if(!searchMode){
      return AppBar(
          title: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),

            child: Center(
              child: searchBar(),
            ),
          ),
          actions: <Widget>[
            const Icon(Icons.brightness_1_outlined),
            appbarMenu(context),
          ]
      );
    }
    return AppBar(
      title: TextField(

        decoration: InputDecoration(suffixText: _foundMatches),
        onChanged: (string){
          _webViewController.findAllAsync(find: string);
        },
      ),
      actions: [
        IconButton(
            onPressed: (){
              _webViewController.findNext(forward: false);
            },
            icon: const Icon(Icons.keyboard_arrow_up_rounded)
        ),
        IconButton(
            onPressed: (){
              _webViewController.findNext(forward: true);
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded)
        ),
        IconButton(onPressed: (){
          setState(() {
            clearFindWorld();
          });
        }, icon: const Icon(Icons.clear)),
      ],
    );
  }

  void clearFindWorld(){
    searchMode=false;
    _webViewController.findAllAsync(find: "");
  }


  Widget searchBar(){
    return TextField(
      controller: searchBarTextController,
      focusNode: searchBarFocusNode,
      keyboardType: TextInputType.url,
      onSubmitted: (text){
        search(text);
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchBarTextController.text="";
              searchBarFocusNode.requestFocus();
            },
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              search(searchBarTextController.text);
            },
          ),
          hintText: 'Search...',
          border: InputBorder.none),
    );
  }


  String removeHttp(String str){
    if (str.length>=7 && str.substring(0, 7)=='http://') {
      return str.substring(7);
    }
    else if (str.length>=8 && str.substring(0, 8) == 'https://') {
      return str.substring(8);
    }
    return str;
  }

  void search(String str){
    var txt=formatToUrl(str);
    txt = removeHttp(txt);

    _webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(txt)));
  }

  String formatToUrl(String str){
    RegExp exp = RegExp(r"^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.?)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$|^((\\(\\[^\s\\]+)+|([A-Za-z]:(\\)?|[A-z]:(\\[^\s\\]+)+))(\\)?)$");
    if(exp.firstMatch(str)!=null && (str.contains(".") || str.contains("/"))){
      return str;
    }
    if(searchEngine=="google"){
      return r"https://www.google.com/search?q="+str.replaceAll(" ", "+");
    }
    if(searchEngine=="lilo"){
      return r"https://search.lilo.org/?q="+str.replaceAll(" ", "+");
    }
    return str;
  }

}