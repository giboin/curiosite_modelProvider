import 'package:curiosite/TabView.dart';
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

  List<String> favorites =[];
  List<String> history=[];
  List<TabView> tabs=[];
  ValueNotifier<String> foundMatches =ValueNotifier<String>("0/0");
  TextEditingController searchBarTextController = TextEditingController();
  FocusNode searchBarFocusNode = FocusNode();
  ValueNotifier<bool> isFav = ValueNotifier(false);
  ValueNotifier<bool> isSecure = ValueNotifier(true);
  ValueNotifier<int> currentTabIndexNotifier=ValueNotifier(0);

  int get currentTabIndex=>currentTabIndexNotifier.value;
  set currentTabIndex(int index){
    currentTabIndexNotifier.value=index;
  }

  String searchEngine='google';
  String home="google.com";
  bool isHttpHidden=true;
  bool iswwwHidden=false;
  bool enableThirdPartyCookies=false;
  bool enableBackButton=false;


  void init() {
    loadHistory();
    loadFavorites();
    loadEngine();
    loadHomePage();
    loadEnableThirdPartyCookies();
    loadEnableBackButton();
    loadIsHttpHidden();
    loadIswwwHidden();
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
      newTab(url: formatUrl(str.substring(0,str.indexOf(" ")), removeHttp: true, removeWww: true), incognito: str.substring(str.indexOf(" ")+1)=="true");
    }
  }

  // if list is null, just saves the current to the database, and if not it also instanciates tabs with list
  Future<void> saveTabs({List<TabView>? list}) async {
    final prefs = await SharedPreferences.getInstance();
    if(list!=null){
      tabs=list;
    }
    List<String> tmp = [currentTabIndex.toString()];
    for(TabView tab in tabs){
      tmp.add(tab.url+" "+tab.incognito.toString());
    }
      prefs.setStringList('tabs', tmp);
  }

  Future<void> tempSaveTabs({List<TabView>? list}) async{
    final prefs = await SharedPreferences.getInstance();
    if(list!=null){
      tabs=list;
    }
    List<String> tmp = [currentTabIndex.toString()];
    for(TabView tab in tabs){
      tmp.add(tab.url+" "+tab.incognito.toString());
      //url
      //incognito
      //screenshot?
      //favicon?

      //json
    }
    prefs.setStringList('tabs', tmp);
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

  Future<void> loadHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('homePage')) {
      return;
    }
    home = prefs.getString('homePage') ??"google.com";
  }
  Future<void> saveHomePage(String str) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('homePage', str);
    home=str;
  }

  Future<void> loadIsHttpHidden() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('isHttpHidden')) {
      return;
    }
    isHttpHidden = prefs.getBool('isHttpHidden') ??true;
  }
  Future<void> saveIsHttpHidden(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isHttpHidden', bool);
    isHttpHidden=bool;
  }

  Future<void> loadIswwwHidden() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('iswwwHidden')) {
      return;
    }
    iswwwHidden = prefs.getBool('iswwwHidden') ??true;
  }
  Future<void> saveIswwwHidden(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('iswwwHidden', bool);
    iswwwHidden=bool;
  }

  Future<void> loadEnableThirdPartyCookies() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('enableThirdPartyCookies')) {
      return;
    }
    enableThirdPartyCookies = prefs.getBool('enableThirdPartyCookies') ??true;
  }
  Future<void> saveEnableThirdPartyCookies(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableThirdPartyCookies', bool);
    enableThirdPartyCookies=bool;
  }

  Future<void> loadEnableBackButton() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('enableBackButton')) {
      return;
    }
    enableBackButton = prefs.getBool('enableBackButton') ??true;
  }
  Future<void> saveEnableBackButton(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableBackButton', bool);
    enableBackButton=bool;
  }



  void newTab({String? url, bool incognito=false}) {
    tabs.add(TabView(key: GlobalKey(), url:url??home, incognito: incognito, webOExplorerI: ValueNotifier(0),));
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

  bool changeBarText(String str){
    if(!searchBarFocusNode.hasFocus){
      searchBarTextController.text=str;
      return true;
    }
    return false;
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

  void isSecureUpdate({String? url}){
    isSecure.value=(url??tabs[currentTabIndex].url).substring(0,8)=="https://";
  }

  void clearFindWorld(){
    searchMode=false;
    tabs[currentTabIndex].webController.findAllAsync(find: "");
  }

  void search(String str){
    var txt=formatToUrl(str);
    txt = formatUrl(txt, removeHttp: true, removeWww: false);
    tabs[currentTabIndex].webController.loadUrl(urlRequest: URLRequest(url: Uri.parse(txt)));
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

  String formatUrlForText(String str){
    return formatUrl(str, removeHttp: isHttpHidden, removeWww: iswwwHidden);
  }
  String formatUrl(String str, {bool removeHttp=true, bool removeWww=false}){
    if(!removeHttp && !removeWww){
      return str;
    }
    String withoutHttp=str;
    bool isHttp=false;
    bool isHttps=false;
    if (str.length>=7 && str.substring(0, 7)=='http://') {
      isHttp=true;
      withoutHttp=str.substring(7);

    }
    else if (str.length>=8 && str.substring(0, 8) == 'https://') {
      isHttps=true;
      withoutHttp=str.substring(8);
    }
    if(!removeWww){
      return withoutHttp;
    }

    String http = removeHttp?'':(isHttp?'http://':(isHttps?'https://':''));
    if(withoutHttp.length>=4 && withoutHttp.substring(0,4)=="www."){

      return http+withoutHttp.substring(4);
    }
    else{
      return http+withoutHttp;
    }


  }



}

