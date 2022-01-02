import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  QRViewController? controller;


  @override
  Widget build(BuildContext context) => SafeArea(
     child: Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQrView(context),
          Positioned(
            bottom: 10,
            child: buildResult())
        ],
      ),
    ),
  );

  Widget buildResult() => 
  
  Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white24,
    ),
    child: Text(
      barcode != null ? 'Result : ${barcode!.code}' : 'Scan a code',
      maxLines: 3,
    ),
  );


  void onQrViewCreated(QRViewController controller) {
      setState(() {
        this.controller= controller;
      });
      controller.scannedDataStream.listen((barcode) => 
        setState(() {
          this.barcode = barcode;
        })
      );
  }

  Widget buildQrView(BuildContext context) => QRView(
    key: qrKey,
    onQRViewCreated: onQrViewCreated,
    overlay: QrScannerOverlayShape(
      borderRadius: 10,
      borderLength: 20,
      borderWidth: 10,
      cutOutSize: MediaQuery.of(context).size.width*0.8,
      ),
    );




 // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

}
