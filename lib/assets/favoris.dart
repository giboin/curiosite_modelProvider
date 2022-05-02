

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Favoris extends StatefulWidget {
  Favoris({Key? key}) : super(key: key);

  @override
  _FavorisState createState() => _FavorisState();
}

class _FavorisState extends State<Favoris> {

  var favorisList = ["Titre\nurl"];
  String filter="";

  Future<void> _getFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('favoris')) {
      return;
    }
    setState(() {
      favorisList = prefs.getStringList('favoris') ?? ["erreur"];
    });
  }

  Future<void> _saveFavoris(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoris', list);
    setState(() {
      favorisList=list;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFavoris();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favoris"),
        actions: [
          IconButton(
            icon:const Icon(Icons.clear),
            onPressed: (){
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                        onPressed: (){
                          favorisList=[];
                          _saveFavoris(favorisList);
                          Navigator.pop(context);
                        },
                        child: const Text("Oui")
                    ),
                    OutlinedButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text("Non")
                    )
                  ],
                  title: const Text("effacer les favoris"),
                  content: const Text("Voulez vous vraiment effacer les favoris?"),
                );
              });

            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
              margin:const EdgeInsets.all(10),
              child:TextField(
                decoration: const InputDecoration(hintText: "rechercher..."),
                onChanged: (String str){
                  setState(() {
                    filter=str;
                  });
                },
              )),
          Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    String item = favorisList[favorisList.length-index-1];
                    String title = item.substring(0,item.indexOf("\n"));
                    String url = item.substring(item.indexOf("\n")+1);
                    if(item.toLowerCase().contains(filter.toLowerCase())){
                      return ListTile(
                        title: SizedBox(
                            height: 25,
                            child:Text(title, overflow: TextOverflow.fade, softWrap: false,)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(
                            height: 20,
                            child:Text(url, overflow: TextOverflow.fade, softWrap: false,),
                          )
                        ],),
                        trailing: PopupMenuButton(
                          onSelected: (selectedValue){
                            switch(selectedValue){
                              case 1:
                              //supprimer
                                favorisList.remove(favorisList.elementAt(favorisList.length-index-1));
                                _saveFavoris(favorisList);
                                break;
                              case 2:
                              //copy to cliboard
                                Clipboard.setData(ClipboardData(text: url));

                                break;
                              default: break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem(child: Text("supprimer"), value: 1,),
                              const PopupMenuItem(child: Text("copier le lien"), value:2)
                            ];
                          },
                        ),
                        onTap: (){
                          Navigator.pop(context, [url]);
                        },
                      );
                    }
                    else{
                      return const SizedBox(height: 0,width: 0,);
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    String item = favorisList[favorisList.length-index-1];
                    if(item.toLowerCase().contains(filter.toLowerCase())){
                      return const Divider(height: 3, color: Colors.grey);
                    }
                    return const SizedBox(height: 0,width: 0,);
                    },
                  itemCount: favorisList.length
              )
          )
        ],
      ),
    );
  }

}