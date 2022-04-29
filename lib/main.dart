
import 'dart:async';
import 'package:curiosite/parametres.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends MaterialApp {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late InAppWebViewController _webViewController;
  String url = "";
  double progress = 0;
  Icon pcVersion=const Icon(Icons.check_box_outline_blank, color: Colors.black,);
  TextEditingController searchText = TextEditingController();
  late String searchEngine;

  Future<void> _getEngine() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('engine')) {
      return;
    }
    setState(() {
      searchEngine = prefs.getString('engine') ?? "erreur";
    });
  }

  @override
  void initState() {
    super.initState();
    _getEngine();
  }

  @override
  Widget build(BuildContext context) {
    searchText.text=url;
    return MaterialApp(
        home: WillPopScope(
            onWillPop: () async {
              if (await _webViewController.canGoBack()){
                _webViewController.goBack();
                return false;
              }
              return true;
            },
            child: Builder(builder:(context)=>Scaffold(
              appBar: AppBar(
                  leading:IconButton(
                    icon:const Icon(Icons.arrow_back),
                    onPressed: (){
                      _webViewController.goBack();
                    },
                  ),
                  title: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),

                    child: Center(
                      child: searchBar(),
                    ),
                  ),
                  actions: <Widget>[
                    const Icon(Icons.brightness_1_outlined),
                    appbarMenu(context),
                  ]
              ),



//=======================================================
//                web View
//=======================================================
              body: Column(children: <Widget>[
                Container(
                    child: progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container()),
                Expanded(
                  child: InAppWebView(
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            preferredContentMode: pcVersion.icon==Icons.check_box_outline_blank? UserPreferredContentMode.MOBILE : UserPreferredContentMode.DESKTOP
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      _webViewController = controller;
                      _webViewController.loadUrl(urlRequest: URLRequest(url:Uri(path: "flutter.dev/")));
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                      });
                    },
                    onLoadStop: (controller, url) async {
                      setState(() {
                        this.url = url.toString();
                      });
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
        )
    );
  }

  Widget appbarMenu(BuildContext context){
    return PopupMenuButton(
        onSelected: (result){
          switch(result){
            case 7: _openSettings(context); break;
            case 1: break;
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
                if (pcVersion.icon==Icons.check_box_outline_blank){
                  pcVersion=const Icon(Icons.check_box, color: Colors.black,);
                }else{
                  pcVersion=const Icon(Icons.check_box_outline_blank, color: Colors.black,);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.computer, color: Colors.black,),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  const Text("Version pour ordi"),
                  Container(margin: const EdgeInsets.only(right: 20),),
                  pcVersion,
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


  Widget searchBar(){
    return TextField(
      controller: searchText,
      keyboardType: TextInputType.url,
      onSubmitted: (text){
        search(text);
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchText.text="";
            },
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              search(searchText.text);
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