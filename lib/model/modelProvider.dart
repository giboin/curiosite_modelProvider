import 'package:curiosite/TabWebView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelProvider extends InheritedWidget {
  final AppModel model;

  const ModelProvider({Key? key, required this.model, required Widget child})
      : assert(model != null),
        assert(child != null),
        super(key: key, child: child);

  static AppModel of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<ModelProvider>() as ModelProvider)
          .model;

  @override
  bool updateShouldNotify(ModelProvider oldWidget) => model != oldWidget.model;
}


class AppModel with ChangeNotifier{


  bool searchMode=false;

  ValueNotifier<String> foundMatches =ValueNotifier<String>("0/0");
  TextEditingController searchBarTextController = TextEditingController();
  FocusNode searchBarFocusNode = FocusNode();
  String searchEngine='google';
  List<String> favorites =[];
  List<String> history=[];
  ValueNotifier<bool> isFav = ValueNotifier(false);
  List<TabWebView> tabs=[];
  int currentTabIndex=0;
  String home="google.com";


  void init() {
    loadHistory();
    loadFavorites();
    loadEngine();
  }



  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('history')) {
      return;
    }
    history = prefs.getStringList('history') ?? ["erreur"];
  }
  Future<void> saveHistory(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', list);
    history=list;
  }
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('favorites')) {
      return;
    }
    favorites = prefs.getStringList('favorites') ?? ["erreur"];
  }
  Future<void> saveFavorites(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', list);
    favorites=list;
  }

  Future<void> loadEngine() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('engine')) {
      return;
    }
    searchEngine = prefs.getString('engine') ??"google";
  }
  Future<void> saveEngine(String str) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('engine', str);
    searchEngine=str;
  }

  Future<void> loadTabs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('tabs')) {
      newTab();
      currentTabIndex=0;
      return;
    }
    List<String> tabsString = prefs.getStringList('tabs') ??[];
    if(tabsString.isEmpty){
      newTab();
      currentTabIndex=0;
      return;
    }
    currentTabIndex=int.parse(tabsString[0]);
    tabsString.removeAt(0);
    for (String str in tabsString) {
      newTab(url: removeHttp(str));
    }
  }
  Future<void> saveTabs({List<TabWebView>? list}) async {
    final prefs = await SharedPreferences.getInstance();
    if(list!=null){
      tabs=list;
    }
    List<String> tmp = [currentTabIndex.toString()];
    for(TabWebView tab in tabs){
      tmp.add(tab.url);
    }
    prefs.setStringList('tabs', tmp);
  }



  void newTab({String? url, bool incognito=false}) {
    if(url==null){
      tabs.add(TabWebView(key: GlobalKey(), url:home, incognito: incognito));
    }
    else{
      tabs.add(TabWebView(key: GlobalKey(), url:url, incognito: incognito));
    }
    saveTabs();

  }

  void removeTab(int index){
    if(currentTabIndex>=index){
      currentTabIndex=currentTabIndex-1;
    }
    tabs.removeAt(index);

    if(currentTabIndex==-1){
      if(tabs.isEmpty){
        newTab();
      }
      currentTabIndex=0;
    }
    saveTabs();
  }

  void isFavUpdate({String? url}){
    isFav.value=false;
    for(String str in favorites){
      if(str.substring(str.indexOf("\n"),str.length-1).trim()==(url??tabs[currentTabIndex].url).trim()){
        isFav.value=true;
        return;
      }
    }
  }

  void clearFindWorld(){
    searchMode=false;
    tabs[currentTabIndex].controller.findAllAsync(find: "");
  }

  void search(String str){
    var txt=formatToUrl(str);
    txt = removeHttp(txt);
    tabs[currentTabIndex].controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(txt)));
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

  String removeHttp(String str){
    if (str.length>=7 && str.substring(0, 7)=='http://') {
      return str.substring(7);
    }
    else if (str.length>=8 && str.substring(0, 8) == 'https://') {
      return str.substring(8);
    }
    return str;
  }


}

