
import 'package:curiosite/model/modelProvider.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _ParamState createState() => _ParamState();
}

class _ParamState extends State<SettingsPage> {

  TextEditingController homePageController = TextEditingController();


  @override
  void didChangeDependencies() {
    homePageController.text=ModelProvider.of(context).home;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {


    List<Widget> children=[
      ListTile(
        leading: const Text("moteur de recherche"),
        title: DropdownButton<String>(
            items: <String>['google','lilo'].map((String value) {
              //La fonction crée un objet qui aura la même valeur et le même texte, à partir du tableau d'objet
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              if(value!=null) {
                ModelProvider.of(context).saveEngine(value);
                setState(() {});
              }
            },
            value: ModelProvider.of(context).searchEngine
        ),
      ),

      ListTile(
        leading: const Text("page d'accueil:"),
        title:TextField(
          controller: homePageController,
          keyboardType: TextInputType.url,
        ),
        trailing: OutlinedButton(
          child: const Text("ok"),
          onPressed: (){
            showDialog(context: context, builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text("Etes vous sûr.e?"),
                actions: [
                  OutlinedButton(onPressed: (){
                    ModelProvider.of(context).saveHomePage(homePageController.text);
                    Navigator.pop(ctx);
                  }, child: const Text("ok")),
                  OutlinedButton(onPressed: (){
                    Navigator.pop(ctx);
                  }, child: const Text("nope")),
                ],
              );
            });
          },
        ),
      ),

      ListTile(
          title:Row(
            children: [
              Expanded(
                  child:ListTile(
                    leading: const Text("Cacher http(s)://"),
                    title: Checkbox(
                      value: ModelProvider.of(context).isHttpHidden,
                      onChanged: (value){
                        if(value!=null) {
                          setState(() {
                            ModelProvider.of(context).saveIsHttpHidden(value);
                          });
                        }
                      },
                    ),
                  )
              ),
              Container(width: 1, height: 40,color: Colors.grey,),
              Expanded(
                  child:ListTile(
                    leading: const Text("Cacher www."),
                    title: Checkbox(
                      value: ModelProvider.of(context).iswwwHidden,
                      onChanged: (value){
                        if(value!=null) {
                          setState(() {
                            ModelProvider.of(context).saveIswwwHidden(value);
                          });
                        }
                      },
                    ),
                  )
              )
            ],
          )
      ),
      ListTile(
        leading: IconButton(
          icon:const Icon(Icons.info),
          onPressed: (){
            showDialog(
                context: context,
                builder: (ctx){
                  return const AlertDialog(
                      content:Text("Les cookies tiers (third party cookies en anglais) sont des cookies qui ne sont pas déposés par le site consulté mais par un partenaire technologique qui affiche un composant sur le site, en général pour de la publicité. Ces cookies sont de plus en plus critiqués pour des raisons de confidentialité, google est d'ailleurs en passe de les interdire sur chrome.")
                  );
                }
            );
          },
        ),
        title: const Text("autoriser les cookies tiers"),
        trailing:Checkbox(
            value: ModelProvider.of(context).enableThirdPartyCookies,
            onChanged: (value){
              setState(() {
                ModelProvider.of(context).saveEnableThirdPartyCookies(value??false);
              });
            }),
      ),
      ListTile(
        leading: Icon(Icons.arrow_back),
        title: Text("afficher le bouton retour"),
        trailing: Checkbox(
          value: ModelProvider.of(context).enableBackButton,
          onChanged: (value){
            setState(() {
              ModelProvider.of(context).saveEnableBackButton(value??false);
            });
          },
        ),
      )
    ];


    return Scaffold(
        appBar: AppBar(title: const Text("Paramètres"),),
        body: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: children.length,
            separatorBuilder: (BuildContext context,
                int index) => const Divider(height: 3, color: Colors.grey),
            itemBuilder: (BuildContext context, int index) {
              return children[index];

            }
        )
    );
  }

}