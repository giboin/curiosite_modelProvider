
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

import 'model/modelProvider.dart';

class TabWebView extends StatefulWidget {
  final GlobalKey<_TabWebViewState> key;
  TabWebView({required this.key, this.incognito=false, required this.url}) : super(key: key);

  String url;
  bool incognito;
  late InAppWebViewController controller;
  bool pcVersion =  UserPreferredContentMode.RECOMMENDED==UserPreferredContentMode.DESKTOP;

  @override
  _TabWebViewState createState() => _TabWebViewState();
}

class _TabWebViewState extends State<TabWebView> {

  double progress = 0;

  @override
  void didChangeDependencies() {
    ModelProvider.of(context).addListener(() => setState((){}));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          child: progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : Container()),
      Expanded(
          child:InAppWebView(
            initialOptions: InAppWebViewGroupOptions(android: AndroidInAppWebViewOptions(useHybridComposition: true)),
            onLoadStart:(_webViewController, uri){
            },
            onFindResultReceived: (controller, activeMatchOrdinal, numberOfMatches, isDoneCounting) {
              if (isDoneCounting) {
                setState(() {
                  ModelProvider.of(context).foundMatches.value = (numberOfMatches>0?(activeMatchOrdinal+1).toString() + "/" +
                      numberOfMatches.toString():"0/0");
                });
              }
            },
            initialUrlRequest: URLRequest(url:Uri.parse(widget.url)),
            onWebViewCreated: (InAppWebViewController controller) {
              widget.controller = controller;
              widget.controller.setOptions(options: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(incognito: widget.incognito)));
            },
            onLoadStop: (controller, url) async {
              var title = await widget.controller.getTitle();
              var date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
              widget.url = url.toString();
              ModelProvider.of(context).searchBarTextController.text=ModelProvider.of(context).formatUrlForText(widget.url);

              if(!widget.incognito){
                if(ModelProvider.of(context).history.isEmpty){
                  ModelProvider.of(context).history.add("$date$title\n${url.toString()}");
                  ModelProvider.of(context).saveHistory(ModelProvider.of(context).history);
                }else{
                  String lastEntry=ModelProvider.of(context).history.last;
                  if(lastEntry.substring(lastEntry.indexOf("\n")).trim()!=url.toString().trim()){
                    ModelProvider.of(context).history.add("$date$title\n${url.toString()}");
                    ModelProvider.of(context).saveHistory(ModelProvider.of(context).history);
                  }
                }
              }

              ModelProvider.of(context).saveTabs();
              ModelProvider.of(context).isFavUpdate(url:url.toString());
              ModelProvider.of(context).isSecureUpdate(url:url.toString());

            },
            onProgressChanged: (InAppWebViewController controller, int prog) {
              setState(() {
                progress = (prog / 100);
              });
            },
          )
      )
    ]
    );
  }
}