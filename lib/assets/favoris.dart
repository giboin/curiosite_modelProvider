

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Historique extends StatefulWidget {
  Historique({Key? key}) : super(key: key);

  @override
  _HistoState createState() => _HistoState();
}

class _HistoState extends State<Historique> {

  var histoList = ["Titre\nurl"];
  String filter="";

  Future<void> _getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('history')) {
      return;
    }
    setState(() {
      histoList = prefs.getStringList('history') ?? ["erreur"];
    });
  }

  Future<void> _saveHistory(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', list);
    setState(() {
      histoList=list;
    });
  }

  @override
  void initState() {
    super.initState();
    _getHistory();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique"),
        actions: [
          IconButton(
            icon:const Icon(Icons.clear),
            onPressed: (){
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                        onPressed: (){
                          histoList=[];
                          _saveHistory(histoList);
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
                  title: const Text("effacer l'historique"),
                  content: const Text("Voulez vous vraiment effacer l'historique?"),
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
                    String item = histoList[histoList.length-index-1];
                    String date= item.substring(0,19);
                    String title = item.substring(19,item.indexOf("\n"));
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
                          ),
                          Text(date)
                        ],),
                        trailing: PopupMenuButton(
                          onSelected: (selectedValue){
                            switch(selectedValue){
                              case 1:
                              //supprimer
                                histoList.remove(histoList.elementAt(histoList.length-index-1));
                                print(histoList.toString());
                                _saveHistory(histoList);
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
                    String item = histoList[histoList.length-index-1];
                    if(item.toLowerCase().contains(filter.toLowerCase())){
                      return const Divider(height: 3, color: Colors.grey);
                    }
                    return const SizedBox(height: 0,width: 0,);
                    },
                  itemCount: histoList.length
              )
          )
        ],
      ),
    );
  }

}