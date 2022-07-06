

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/modelProvider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  List<String> get favs => ModelProvider.of(context).favorites;
  set favs(List<String> list){
    ModelProvider.of(context).saveFavorites(list);
  }
  String filter="";

  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState((){}));
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoris"),
        actions: [
          IconButton(
            icon:const Icon(Icons.clear),
            onPressed: (){
              showDialog(context: context, builder: (ctx){
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                        onPressed: (){
                          setState(() {
                            favs=[];
                          });
                          Navigator.pop(ctx);
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
                    String item = favs[favs.length-index-1];
                    String title = item.substring(0,item.indexOf("\n"));
                    String url = item.substring(item.indexOf("\n")+1,item.length-1);
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
                                setState(() {
                                  favs.removeAt(favs.length-index-1);
                                });
                                ModelProvider.of(context).saveFavorites(favs);
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
                    String item = favs[favs.length-index-1];
                    if(item.toLowerCase().contains(filter.toLowerCase())){
                      return const Divider(height: 3, color: Colors.grey);
                    }
                    return const SizedBox(height: 0,width: 0,);
                  },
                  itemCount: favs.length
              )
          )
        ],
      ),
    );
  }

}