import 'package:curiosite/model/modelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoState createState() => _HistoState();
}

class _HistoState extends State<HistoryPage> {

  String filter="";

  List<String> get hist => ModelProvider.of(context).history;
  set hist(List<String> list){
    ModelProvider.of(context).saveHistory(list);
  }

  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState((){}));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
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
                            hist=[];
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
                    String item = hist[hist.length-index-1];
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
                                setState(() {
                                  hist.removeAt(hist.length-index-1);
                                });
                                ModelProvider.of(context).saveHistory(hist);
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
                    String item = hist[hist.length-index-1];
                    if(item.toLowerCase().contains(filter.toLowerCase())){
                      return const Divider(height: 3, color: Colors.grey);
                    }
                    return const SizedBox(height: 0,width: 0,);
                  },
                  itemCount: hist.length
              )
          )
        ],
      ),
    );
  }

}