import 'package:curiosite/model/CustomImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';

class LongPressAlertDialog extends StatefulWidget {
  static const List<InAppWebViewHitTestResultType> HIT_TEST_RESULT_SUPPORTED = [
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE
  ];

  LongPressAlertDialog({Key? key, required this.hitTestResult, this.requestFocusNodeHrefResult})
      : super(key: key);

  final InAppWebViewHitTestResult hitTestResult;
  final RequestFocusNodeHrefResult? requestFocusNodeHrefResult;

  @override
  _LongPressAlertDialogState createState() => _LongPressAlertDialogState();
}

class _LongPressAlertDialogState extends State<LongPressAlertDialog> {
  var _isLinkPreviewReady = false;




  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildDialogLongPressHitTestResult(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDialogLongPressHitTestResult(BuildContext context) {
    if (widget.hitTestResult.type ==
        InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
        widget.hitTestResult.type ==
            InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE || (
        widget.hitTestResult.type ==
            InAppWebViewHitTestResultType.IMAGE_TYPE &&
            widget.requestFocusNodeHrefResult != null
            && widget.requestFocusNodeHrefResult!.url != null &&
            widget.requestFocusNodeHrefResult!.url.toString().isNotEmpty
    )) {
      return <Widget>[
        _buildLinkTile(),
        const Divider(),
        _buildLinkPreview(),
        const Divider(),
        _buildOpenNewTab(context),
        _buildOpenNewIncognitoTab(),
        _buildCopyAddressLink(),
        _buildShareLink(),
      ];
    } else if (widget.hitTestResult.type ==
        InAppWebViewHitTestResultType.IMAGE_TYPE) {
      return <Widget>[
        _buildImageTile(),
        const Divider(),
        _buildOpenImageNewTab(),
        _buildDownloadImage(),
        //_buildSearchImageOnGoogle(),
        _buildShareImage(),
      ];
    }
    return [];
  }

  Widget _buildLinkTile() {
    var url = widget.requestFocusNodeHrefResult?.url ?? Uri.parse("about:blank");
    var faviconUrl = Uri.parse(url.origin + "/favicon.ico");

    var title = widget.requestFocusNodeHrefResult?.title ?? "Link";

    return ListTile(
      leading: CustomImage(url: widget.requestFocusNodeHrefResult?.src != null ? Uri.parse(widget.requestFocusNodeHrefResult!.src!) : faviconUrl, maxWidth: 30.0, height: 30.0,),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,),
      subtitle: Text(
        widget.requestFocusNodeHrefResult?.url?.toString() ?? "",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
    );
  }

  Widget _buildLinkPreview() {
    return ListTile(
      title: Center(child: const Text("Link Preview")),
      subtitle: Container(
        padding: EdgeInsets.only(top: 15.0),
        height: 250,
        child: IndexedStack(
          index: _isLinkPreviewReady ? 1 : 0,
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            ),
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: widget.requestFocusNodeHrefResult?.url
              ),
              initialOptions: InAppWebViewGroupOptions(
                  android: AndroidInAppWebViewOptions(
                      useHybridComposition: true,
                      verticalScrollbarThumbColor: Color.fromRGBO(0, 0, 0, 0.5),
                      horizontalScrollbarThumbColor: Color.fromRGBO(0, 0, 0, 0.5)
                  )
              ),
              onProgressChanged: (controller, progress) {
                if (progress > 50) {
                  setState(() {
                    _isLinkPreviewReady = true;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOpenNewTab(BuildContext ctx) {
    return ListTile(
      title: const Text("Ouvrir dans un nouvel onglet"),
      onTap: () {
        Navigator.pop(context, {'action':'newTab', 'url':widget.requestFocusNodeHrefResult?.url.toString()});
      },
    );
  }

  Widget _buildOpenNewIncognitoTab() {
    return ListTile(
      title: const Text("Ouvrir en navigation privée"),
      onTap: () {
          Navigator.pop(context, {'action':'newTabInc', 'url':widget.requestFocusNodeHrefResult?.url.toString()});
      },
    );
  }

  Widget _buildCopyAddressLink() {
    //TODO check link address on copy
    return ListTile(
      title: const Text("Copier l'adresse du lien"),
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.requestFocusNodeHrefResult?.url?.toString() ?? ""));
        Navigator.pop(context, {'action':'copyLink'});
      },
    );
  }

  Widget _buildShareLink() {
    //TODO share text
    return ListTile(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        Text("partager..."),
        Padding(
          padding: EdgeInsets.only(right: 12.5),
          child: Icon(
            Icons.share,
            color: Colors.black54,
            size: 20.0,
          ),
        )
      ]),
      onTap: () {
        if (widget.requestFocusNodeHrefResult?.url?.toString() != null) {
          Share.share(widget.requestFocusNodeHrefResult?.url?.toString()??"");
        }
        Navigator.pop(context,{'action':'shareLink'});
      },
    );
  }

  Widget _buildImageTile() {
    return ListTile(
      contentPadding:
      const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
      title:CustomImage(url: Uri.parse(widget.hitTestResult.extra!), maxWidth: 200.0, height: 200.0)
    );
  }


  Widget _buildOpenImageNewTab() {
    return ListTile(
      title: const Text("Image in a new tab"),
      onTap: () {
        Navigator.pop(context,{'action':'newTab','url': Uri.parse(widget.hitTestResult.extra ?? "about:blank").toString()});
      },
    );
  }

  Widget _buildDownloadImage() {
    return ListTile(
      title: const Text("Download image"),
      onTap: () async {
       //TODO download image
        Navigator.pop(context);
      },
    );
  }

  //doesn't work, I don't understand how google builds his urls for image searchs
  Widget _buildSearchImageOnGoogle() {
    return ListTile(
      title: const Text("Search this image on Google"),
      onTap: () {
        if (widget.hitTestResult.extra != null) {
          var url = "https://www.google.com/search?tbs=" +
              widget.hitTestResult.extra!.substring(widget.hitTestResult.extra!.indexOf(";base64,")+8);
          Navigator.pop(context,{'action':'newTab','url': url});
        }
        else {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildShareImage() {
    //TODO share image
    return ListTile(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Share image"),
        Padding(
          padding: EdgeInsets.only(right: 12.5),
          child: Icon(
            Icons.share,
            color: Colors.black54,
            size: 20.0,
          ),
        )
      ]),
      onTap: () {
        if (widget.hitTestResult.extra != null) {
          Share.share(widget.hitTestResult.extra!);
        }
        Navigator.pop(context,{'action':'shareImage'});
      },
    );
  }
}