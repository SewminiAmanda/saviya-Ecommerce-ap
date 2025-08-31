import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PayHereWebviewPage extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const PayHereWebviewPage({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final htmlForm =
        """
    <html>
      <body>
        <form id="payhereForm" method="post" action="https://sandbox.payhere.lk/pay/checkout">
          ${paymentData.entries.map((e) => '<input type="hidden" name="${e.key}" value="${e.value}">').join()}
        </form>
        <script type="text/javascript">
          document.getElementById('payhereForm').submit();
        </script>
      </body>
    </html>
    """;

    return Scaffold(
      appBar: AppBar(title: const Text("PayHere Payment")),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(data: htmlForm),
        initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
        onLoadStart: (controller, url) {
          if (url != null) {
            if (url.toString().startsWith("myapp://payment-success")) {
              Navigator.pop(context);
              debugPrint("Payment Success!");
            } else if (url.toString().startsWith("myapp://payment-cancel")) {
              Navigator.pop(context);
              debugPrint("Payment Cancelled!");
            }
          }
        },
      ),
    );
  }
}
