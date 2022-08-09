
import 'package:curiosite/ExplorerView/ExplorerView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

import 'ExplorerView/ExplorerController.dart';
import 'LongPressAlertDialog.dart';
import 'model/modelProvider.dart';

class TabView extends StatefulWidget {
  final GlobalKey<_TabViewState> key;
  TabView({required this.key, this.incognito=false, required this.url, required this.webOExplorerI}) : super(key: key);

  String url;
  bool incognito;
  late InAppWebViewController webController;
  ExplorerController explorerController=ExplorerController();
  bool pcVersion =  UserPreferredContentMode.RECOMMENDED==UserPreferredContentMode.DESKTOP;
  ValueNotifier<int> webOExplorerI;

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {

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
          child:ValueListenableBuilder<int>(
              valueListenable: widget.webOExplorerI,
              builder: (BuildContext context, value, Widget? child) {
                return IndexedStack(
                  index: value,
                  children: [
                    InAppWebView(
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform:InAppWebViewOptions(
                            incognito: widget.incognito,
                          ),
                          android: AndroidInAppWebViewOptions(
                              useHybridComposition: true,
                              thirdPartyCookiesEnabled: ModelProvider.of(context).enableThirdPartyCookies
                          )
                      ),
                      onLongPressHitTestResult:(controller, InAppWebViewHitTestResult hitTestResult) async {
                        if (LongPressAlertDialog.HIT_TEST_RESULT_SUPPORTED
                            .contains(hitTestResult.type)) {

                          var requestFocusNodeHrefResult = await widget.webController.requestFocusNodeHref();

                          if (requestFocusNodeHrefResult != null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return LongPressAlertDialog(
                                  hitTestResult: hitTestResult,
                                  requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                                );
                              },
                            ).then((value) {
                              switch(value['action']){
                                case ('newTab'):{
                                  ModelProvider.of(context).newTab(url:value['url']);
                                  ModelProvider.of(context).currentTabIndex=ModelProvider.of(context).tabs.length-1;
                                  ModelProvider.of(context).saveTabs();
                                  ModelProvider.of(context).isSecureUpdate();
                                  ModelProvider.of(context).isFavUpdate();
                                }
                                break;
                                case('newTabInc'):{
                                  ModelProvider.of(context).newTab(url:value['url'],incognito: true);
                                  ModelProvider.of(context).currentTabIndex=ModelProvider.of(context).tabs.length-1;
                                  ModelProvider.of(context).saveTabs();
                                }
                                break;
                                default:{

                                }
                              }
                            }
                            );
                          }
                        }
                      },
                      onLoadStart: (_webViewController, uri) {
                        widget.url=uri.toString();
                        if(ModelProvider.of(context).tabs[ModelProvider.of(context).currentTabIndex].key==widget.key){
                          ModelProvider.of(context).changeBarText(
                              ModelProvider.of(context)
                                  .formatUrlForText(widget.url)
                          );
                        }
                      },
                      onFindResultReceived: (controller, activeMatchOrdinal,
                          numberOfMatches, isDoneCounting) {
                        if (isDoneCounting) {
                          setState(() {
                            ModelProvider.of(context).foundMatches.value =
                            (numberOfMatches > 0 ? (activeMatchOrdinal + 1).toString() + "/" +
                                numberOfMatches.toString() : "0/0");
                          });
                        }
                      },
                      initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                      onWebViewCreated: (InAppWebViewController controller) {
                        widget.webController = controller;
                        widget.webController.setOptions(
                            options: InAppWebViewGroupOptions(
                                crossPlatform: InAppWebViewOptions(
                                    incognito: widget.incognito)));
                      },
                      onLoadStop: (controller, url) async {
                        widget.url = url.toString();
                        if(ModelProvider.of(context).tabs[ModelProvider.of(context).currentTabIndex].key==widget.key){
                          var title = await widget.webController.getTitle();
                          var date = DateFormat("yyyy-MM-dd HH:mm:ss").format(
                              DateTime.now());
                          ModelProvider.of(context).changeBarText(
                              ModelProvider.of(context)
                                  .formatUrlForText(widget.url)
                          );
                          ModelProvider.of(context).saveTabs();

                          if (!widget.incognito) {
                            if (ModelProvider
                                .of(context)
                                .history
                                .isEmpty) {
                              ModelProvider
                                  .of(context)
                                  .history
                                  .add("$date$title\n${url.toString()}");
                              ModelProvider.of(context).saveHistory(
                                  ModelProvider
                                      .of(context)
                                      .history);
                            } else {
                              String lastEntry = ModelProvider
                                  .of(context)
                                  .history
                                  .last;
                              if (lastEntry.substring(lastEntry.indexOf("\n"))
                                  .trim() != url.toString().trim()) {
                                ModelProvider
                                    .of(context)
                                    .history
                                    .add("$date$title\n${url.toString()}");
                                ModelProvider.of(context).saveHistory(
                                    ModelProvider
                                        .of(context)
                                        .history);
                              }
                            }
                          }
                          ModelProvider.of(context).isFavUpdate(
                              url: url.toString());
                          ModelProvider.of(context).isSecureUpdate(
                              url: url.toString());
                        }
                      },
                      onProgressChanged: (InAppWebViewController controller,
                          int prog) {
                        setState(() {
                          progress = (prog / 100);
                        });
                      },
                    ),
                    ExplorerView(
                      controller:widget.explorerController,
                      onChangeDir: (){
                        /*print("test");
                        ModelProvider.of(context).searchBarTextController.text=widget.explorerController.currentPath;
                        print(ModelProvider.of(context).searchBarTextController.text);
                        setState(() {});*/
                      },
                    )
                  ],
                );
              }
          )
      )
    ]
    );
  }
}