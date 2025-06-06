import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:visible/common/toast.dart';
import 'package:visible/widgets/custom_app_bar.dart';

class AllCampaignsReport extends StatefulWidget {
  const AllCampaignsReport({
    super.key,
  });

  @override
  _AllCampaignsReportState createState() => _AllCampaignsReportState();
}

class _AllCampaignsReportState extends State<AllCampaignsReport> {
  bool isLoading = false;
  bool hasSelectedDates = false;
  String id = '';
  DateTime? fromDate;
  bool isLoaded = false;
  DateTime? toDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
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

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        if (toDate != null && toDate!.isBefore(picked)) {
          toDate = null;
        }
      });
      if (toDate != null) {
        _loadReport();
      }
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    if (fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
      });
      _loadReport();
    }
  }

  void _loadReport() {
    if (fromDate == null || toDate == null) return;

    setState(() {
      isLoading = true;
      hasSelectedDates = true;
    });

    // Reload WebView with new dates
    if (webViewController != null) {
      webViewController!
          .loadUrl(
        urlRequest: URLRequest(
          url: WebUri(
              "https://lightslategrey-whale-350840.hostingersite.com/api/v1/campaign/report/timely_campaign_report?from_date=$fromDate&to_date=$toDate"),
          headers: {
            'Accept': '*/*',
            'Access-Control-Allow-Origin': '*',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          },
        ),
      )
          .then((_) {
        // Optional: Add timeout to reset loading state if something goes wrong
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && isLoading) {
            setState(() {
              isLoading = false;
              isLoaded = true;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        centerTitle: false,
        title: "Campaigns Report",
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: !isLoaded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _selectFromDate(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'From',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              fromDate != null
                                                  ? _displayFormat
                                                      .format(fromDate!)
                                                  : 'Select start date',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fromDate != null
                                                    ? Colors.black
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _selectToDate(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'To',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              toDate != null
                                                  ? _displayFormat
                                                      .format(toDate!)
                                                  : 'Select end date',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: toDate != null
                                                    ? Colors.black
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: !hasSelectedDates
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 48,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Please select dates to view the report',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose both start and end dates above',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(
                              "https://lightslategrey-whale-350840.hostingersite.com/api/v1/campaign/report/timely_campaign_report?from_date=$fromDate&to_date=$toDate"),
                          headers: {
                            'Accept': '*/*',
                            'Access-Control-Allow-Origin': '*',
                            'Cache-Control': 'no-cache',
                            'Pragma': 'no-cache',
                            'Content-Type': 'application/json',
                            'Connection': 'keep-alive',
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
                            mixedContentMode: AndroidMixedContentMode
                                .MIXED_CONTENT_ALWAYS_ALLOW,
                            safeBrowsingEnabled: false,
                            allowContentAccess: true,
                            allowFileAccess: true,
                            domStorageEnabled: true,
                            databaseEnabled: true,
                            clearSessionCache: true,
                            thirdPartyCookiesEnabled: true,
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
                          setState(() => isLoading = true);
                        },
                        onLoadStop: (controller, url) {
                          setState(() {
                            isLoading = false;
                            isLoaded = true;
                          });
                        },
                        onLoadError: (controller, url, code, message) {
                          print(
                              'Error loading $url: Code $code, Message: $message');
                          setState(() => isLoading = false);
                        },
                        onDownloadStart: (controller, url) async {
                          print("Download started: $url");
                          await _downloadFile(url.toString(), 'report.pdf');
                        },
                        onReceivedServerTrustAuthRequest:
                            (controller, challenge) async {
                          return ServerTrustAuthResponse(
                              action: ServerTrustAuthResponseAction.PROCEED);
                        },
                      ),
                      if (isLoading)
                        Container(
                          color: Colors.white,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading report...',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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
