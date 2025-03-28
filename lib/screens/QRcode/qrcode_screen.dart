import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:smartbill/screens/PDFList/pdf_list.dart';
import 'package:smartbill/screens/confirmDownload/confirm_download.dart';
import 'package:smartbill/services/pdf.dart';


class QrcodeScreen extends StatefulWidget {
  final String qrResult;
  const QrcodeScreen({super.key, required this.qrResult});

  @override
  State<QrcodeScreen> createState() => _QrcodeScreenState();
}

class _QrcodeScreenState extends State<QrcodeScreen> {
  PdfHandler pdfHandler = PdfHandler();
  bool isUri = true;
  late InAppWebViewController webViewController;
  Map pdfPeru = {};

  //DIAN receipt variables
  String? originalUrl;
  bool hasNavigated = false;


  @override
  void initState() {
    super.initState();
    isValidUri();
  }


  void isValidUri() {
    setState(() {
      isUri = Uri.tryParse(widget.qrResult)?.hasScheme ?? false;
      pdfPeru = pdfHandler.parseQrPeru(widget.qrResult);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSnackbar(String content) {
    var snackbar = SnackBar(content: Text(content));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  //Navigator is changing screens before the file has been created
  Future<void> delayNagivation() async {
    await Future.delayed(const Duration(seconds: 5));
    print("Changing screens");

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Descargar factura"),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
              isUri ?  
              Expanded(
                child: InAppWebView(
                  initialSettings: InAppWebViewSettings(
                    useOnDownloadStart: true,
                    allowFileAccess: true,
                    allowContentAccess: true,
                  ),
                  initialUrlRequest: URLRequest(url: WebUri(widget.qrResult)),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    originalUrl ??= url.toString();
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    //WidgetsBinding.instance.addPostFrameCallback((_) { });
                    if(originalUrl != null && originalUrl != url.toString() && !hasNavigated) {
                      hasNavigated = true;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmDownloadScreen(url: url.toString())));
                    }
                  },
                  onDownloadStartRequest: (controller, request) async {

                    final dir = await getExternalStorageDirectory(); // Returns app's external storage
                    final path = "${dir!.path}/invoices";
                    await Directory(path).create(recursive: true);

                    String fileName = "invoice_${DateTime.now().millisecondsSinceEpoch}.pdf";

                    try {
                        await FlutterDownloader.enqueue(
                        url: request.url.toString(),
                        savedDir: path,
                        fileName: fileName,
                        showNotification: true,
                        openFileFromNotification: true,
                      );
                    
                      showSnackbar("Archivo descargado. Estamos redireccionando.");

                      await delayNagivation();
                        
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PDFListScreen()));

                    } catch(e) {
                      print("ERROR! $e");
                      showSnackbar("Ha ocurrido un problema con el PDF");

                    }
                  },
                ),
              ): 
              SizedBox(
                height: 450,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Factura No. ${pdfPeru['code_start']} - ${pdfPeru['code_end']}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        const SizedBox(height:10),
                        _buildRow("NIF", pdfPeru['ruc_company']),
                        _buildRow("Código", pdfPeru['receipt_id']),
                        _buildRow("IGV", pdfPeru['igv']),
                        _buildRow("Pago", pdfPeru['amount']),
                        _buildRow("Fecha", pdfPeru['date']),
                        _buildRow("RUC Cliente", pdfPeru['ruc_customer']),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 10,
                          child: ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.greenAccent)
                            ),
                            onPressed: () {
                              
                            },
                            child: const Text("Guardar factura")
                          ),
                        )
                      ],
                    ),
                  ),
                )
              )
            
          ],
        ),
      ),
    );
  }
}



  Widget _buildRow(String title, String value) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Text(value,
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),),
        ],
      ),
    );
  }

