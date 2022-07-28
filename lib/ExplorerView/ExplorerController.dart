
import 'package:curiosite/model/file.dart';
import 'package:curiosite/model/storageAPI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ExplorerController extends ChangeNotifier{

  String currentPath;

  List<String>? homes;

  ValueNotifier<List<File>> pathsNotifier = ValueNotifier([]);
  get paths => pathsNotifier.value;
  set paths(list) => pathsNotifier.value=list;

  get parentPath =>currentPath.substring(0,currentPath.lastIndexOf("/"));



  ExplorerController({this.currentPath=""}){
    getHome();
  }

  Future<void> getHome()async{
    homes= await StorageAPI.getHomes();
    if(currentPath==""){
      currentPath = homes?.first??"";
    }
  }

  bool canGoBack(){
    if(homes?.contains(currentPath)??false){
      return false;
    }
    return true;
  }

  void goBack(){
    if(canGoBack()){
      navigateTo(currentPath.substring(0,currentPath.lastIndexOf("/")));
    }
  }

  //navigates to the absolute path given
  void navigateTo(String path) async{
    paths=await StorageAPI.getFiles(path)??[];
    currentPath=path;
  }

}