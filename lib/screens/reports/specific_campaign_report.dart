import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'dart:io';
import 'package:visible/common/toast.dart';
import 'package:visible/widgets/custom_app_bar.dart';

class CampaignReportPage extends StatefulWidget {
  final String campaignId;

  const CampaignReportPage({
    super.key,
    required this.campaignId,
  });

  @override
  _CampaignReportPageState createState() => _CampaignReportPageState();
}

class _CampaignReportPageState extends State<CampaignReportPage> {
  bool isLoading = true;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      HttpOverrides.global = _SSLBypassOverrides();
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await perm.Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        final result = await perm.Permission.manageExternalStorage.request();
        return result.isGranted;
      }
      return true;
    }
    return true;
  }

  Future<void> _downloadFile(String url, String suggestedFilename) async {
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        CommonUtils.showErrorToast('Storage permission denied');
        return;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = suggestedFilename.isNotEmpty
          ? suggestedFilename
          : 'download_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory!.path}/$fileName';

      CommonUtils.showToast('Download started ...');

      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final file = File(filePath);
      await response.pipe(file.openWrite());

      CommonUtils.showToast('File downloaded and saved to Downloads folder');
    } catch (e) {
      print('Download error: $e');
      CommonUtils.showErrorToast('Error downloading file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        centerTitle: false,
        title: "Report",
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(
                  'https://lightslategrey-whale-350840.hostingersite.com/api/v1/campaign/report/campaign_report?campaign_id=${widget.campaignId}')),
              headers: {
                'Accept': '*/*',
                'Access-Control-Allow-Origin': '*',
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache',
                'Content-Type': 'application/json',
                'Connection': 'keep-alive',
                'X-Requested-With': 'XMLHttpRequest',
                'Sec-Fetch-Site': 'same-origin',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Dest': 'empty',
              },
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                useOnLoadResource: true,
                useOnDownloadStart: true,
                useShouldInterceptAjaxRequest: true,
                useShouldInterceptFetchRequest: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                mixedContentMode:
                    AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                safeBrowsingEnabled: false,
                allowContentAccess: true,
                allowFileAccess: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                clearSessionCache: true,
                thirdPartyCookiesEnabled: true,
                // allowUniversalAccessFromFileURLs: true,
                // allowFileAccessFromFileURLs: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              print("Started loading: $url");
              setState(() => isLoading = true);
            },
            onLoadStop: (controller, url) {
              print("Finished loading: $url");
              setState(() => isLoading = false);
            },
            onLoadError: (controller, url, code, message) {
              print('Error loading $url: Code $code, Message: $message');
              setState(() => isLoading = false);
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              print(
                  'HTTP Error loading $url: Status $statusCode, Description: $description');
              setState(() => isLoading = false);
            },
            onDownloadStart: (controller, url) async {
              print("Download started: $url");
              await _downloadFile(url.toString(), 'report.pdf');
            },
            onProgressChanged: (controller, progress) {
              print("Loading progress: $progress%");
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              print("Received server trust auth request: $challenge");
              return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED);
            },
            // onReceivedHttpError: (controller, request, errorResponse) async {
            //   print("Received HTTP error: ${errorResponse.statusCode}");
            // },
          ),
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SSLBypassOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback = (cert, host, port) => true;
}
