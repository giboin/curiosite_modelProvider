import 'package:curiosite/ExplorerView/ExplorerController.dart';
import 'package:curiosite/model/file.dart';
import 'package:curiosite/model/modelProvider.dart';
import 'package:curiosite/model/storageAPI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ExplorerView extends StatefulWidget {
  ExplorerView({Key? key, required this.controller, this.onExplorerViewCreated, this.onChangeDir}) : super(key: key);

  ExplorerController controller;

  @override
  final void Function()? onExplorerViewCreated;

  @override
  final void Function()? onChangeDir;


  @override
  _ExplorerViewState createState() => _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {

  bool bottomBarVisibility=false;

  @override
  void initState(){
    requestPermission();
    if(widget.onExplorerViewCreated!=null){
      widget.onExplorerViewCreated!();
    }
    widget.controller.addListener(() {
      if(widget.onChangeDir!=null){
        widget.onChangeDir!();
      }
    });
    super.initState();
  }

  void requestPermission() async{
    Permission perm = Permission.manageExternalStorage;
    await perm.request();
    widget.controller.navigateTo((await StorageAPI.getHomes())?.first??"");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:ValueListenableBuilder(
          valueListenable: widget.controller.pathsNotifier,
          builder: (BuildContext context, List<File> value, child) {
            return value.isNotEmpty?ListView.builder(
                itemCount: value.length,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                      child:ListTile(
                        leading: Icon(value[index].isFile?Icons.insert_drive_file_outlined:Icons.folder),
                        title: Text(value[index].name),
                        onTap: (){
                          if(!value[index].isFile){
                            widget.controller.navigateTo(widget.controller.paths[index].absolutePath);
                            ModelProvider.of(context).searchBarTextController.text=widget.controller.paths[index].absolutePath;
                            setState(() {});
                          }
                        },
                      )
                  );
                }
            ) :const Center(child: Text("il n'y a rien ici"),);
          },

        ),
        bottomNavigationBar: Visibility(
          visible: bottomBarVisibility,
          child:BottomAppBar(
              child:Row(
                children: [
                  IconButton(
                      onPressed: ()async {

                      },
                      icon: const Icon(Icons.copy)
                  ),
                  IconButton(
                      onPressed: ()async {

                      },
                      icon: const Icon(Icons.cut)
                  ),
                  IconButton(
                      onPressed: ()async {

                      },
                      icon: const Icon(Icons.delete)
                  )
                ],
              )
          ),
        ),
        floatingActionButton: Visibility(
          visible: !bottomBarVisibility,
          child:FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (ctx){
                    return AlertDialog(
                      title: Text("Nouveau..."),
                      content: Expanded(
                      child:ListView.builder(
                            itemBuilder: (buildContext,index){
                              return[
                                ListTile(
                                  leading: const Icon(Icons.folder),
                                  title: const Text("dossier"),
                                  onTap: (){
                                    StorageAPI.createFolder(widget.controller.currentPath, "nouveau-dossier");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.text_snippet_outlined),
                                  title: const Text(" fichier texte (.txt)"),
                                  onTap: (){
                                    StorageAPI.createFile(widget.controller.currentPath, "nouveau-texte.txt");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text("image (.jpg)"),
                                  onTap: (){
                                    StorageAPI.createFile(widget.controller.currentPath, "nouvelle-image.jpg");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text("image (.png)"),
                                  onTap: (){
                                    StorageAPI.createFile(widget.controller.currentPath, "nouvelle-image.png");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.insert_drive_file_outlined),
                                  title: const Text("autre"),
                                  onTap: (){
                                    StorageAPI.createFile(widget.controller.currentPath, "");
                                  },
                                ),
                              ][index];
                            }
                        )
                      )
                    );
                  }
              );
            },
          ),
        )
    );
  }

}