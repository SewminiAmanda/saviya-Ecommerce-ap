import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TalkJsChatPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserEmail;
  final String currentUserPhotoUrl;
  final String otherUserId;
  final String otherUserName;
  final String otherUserEmail;
  final String otherUserPhotoUrl;

  const TalkJsChatPage({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserEmail,
    required this.currentUserPhotoUrl,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserEmail,
    required this.otherUserPhotoUrl,
  }) : super(key: key);

  @override
  State<TalkJsChatPage> createState() => _TalkJsChatPageState();
}

class _TalkJsChatPageState extends State<TalkJsChatPage> {
  String htmlTemplate = "";

  @override
  void initState() {
    super.initState();
    loadChatHtml();
  }

  Future<void> loadChatHtml() async {
    String rawHtml = await rootBundle.loadString(
      "assets/talkjs_chat_template.html",
    );

    String filledHtml = rawHtml
        .replaceAll("__APP_ID__", "tb4MdWGr")
        .replaceAll("__CURRENT_USER_ID__", widget.currentUserId)
        .replaceAll("__CURRENT_USER_NAME__", widget.currentUserName)
        .replaceAll("__CURRENT_USER_EMAIL__", widget.currentUserEmail)
        .replaceAll("__CURRENT_USER_PHOTO__", widget.currentUserPhotoUrl)
        .replaceAll("__OTHER_USER_ID__", widget.otherUserId)
        .replaceAll("__OTHER_USER_NAME__", widget.otherUserName)
        .replaceAll("__OTHER_USER_EMAIL__", widget.otherUserEmail)
        .replaceAll("__OTHER_USER_PHOTO__", widget.otherUserPhotoUrl);

    setState(() {
      htmlTemplate = filledHtml;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: htmlTemplate.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : InAppWebView(
              initialData: InAppWebViewInitialData(data: htmlTemplate),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
              ),
            ),
    );
  }
}
