
import 'dart:convert';
import 'dart:typed_data';

import 'package:curiosite/model/file.dart';
import 'package:flutter/services.dart';

class StorageAPI {

  static const platform = MethodChannel('com.leroux.curiosite/storage_management');


  //static Future<Int32List> extract(Int32List file) async{}
  //static Future<Int32List> compress(Int32List file) async{}

  //returns a list of homes absolute paths. If there is no sd card, homes().length is 1, and it is more if there is
  // other external storages
  static Future<List<String>?> getHomes() async{
    List<String>? paths;
    try {
      final List result = await platform.invokeMethod('getHomes');
      paths = List<String>.from(result);
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      paths = null;
    }
    return paths;
  }

  static Future<List<File>?> getFiles(String uri) async {
    List<File> paths=[];
    try {
      final List result = await platform.invokeMethod('getPaths', {"uri":uri});
      for(var jsonFile in result){
        paths.add(File.fromJSON(jsonDecode(jsonFile)));
      }


    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      return null;
    }
    return paths;
  }

  static Future<Int32List?> getFile(String path) async {
    Int32List? lines;
    try {
      final Int32List result = await platform.invokeMethod('getFile', {"path":path});
      lines = result;
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      lines = null;
    }
    return lines;
  }

  static Future<bool> createFile(String path, String name) async {
    bool success;
    try {
      final bool result = await platform.invokeMethod('createFile', {"path":path,"name":name});
      success = result;
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      success=false;
    }
    return success;
  }

  static Future<bool> createFolder(String path, String name) async {
    bool success;
    try {
      final bool result = await platform.invokeMethod('createFolder', {"path":path,"name":name});
      success = result;
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      success=false;
    }
    return success;
  }

  static Future<bool> rename(String path, String newName) async {
    bool success;
    try {
      final bool result = await platform.invokeMethod('rename', {"path":path, "newName":newName});
      success = result;
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      success=false;
    }
    return success;
  }

  static Future<bool> delete(String path) async {
    bool success;
    try {
      final bool result = await platform.invokeMethod('delete', {"path":path});
      success = result;
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      success=false;
    }
    return success;
  }

  static Future<int> availableSpace(String path) async {
    int space;
    try {
      final int result = await platform.invokeMethod('availableSpace', {"path":path});
      space = result;
    } on PlatformException catch (e) {
      print("error in native code");
      print(e.message);
      space=-1;
    }
    return space;
  }


}