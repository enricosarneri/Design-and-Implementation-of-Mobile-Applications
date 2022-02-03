import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:event_handler/models/event.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  State<StatefulWidget> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  QRViewController? controller;
  bool isQrCodeValid = false;
  String text = 'Scan a QrCode please';

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildQrView(context),
              Positioned(bottom: 10, child: buildResult())
            ],
          ),
        ),
      );

  Widget buildResult() => Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white24,
        ),
        child: Text(
          //(barcode != null && widget.event.getPartecipantList.contains(barcode!.code)) ? 'The Qr code is OK!' : 'Scan a code',
          //barcode != null && isQrCodeValid
          //    ? 'This is a valid QRCode'
          //    : 'Scan a valid Qrcode please',
          barcode != null ? text : 'Scan a QrCode please',
          maxLines: 3,
        ),
      );

  void onQrViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    //bool scanned=false;
    controller.scannedDataStream.listen((barcode) => {
          log(widget.event.getQrCodeList[0]),
          log(barcode.code!),
          setState(() {
            isQrCodeValid = false;
          }),
          for (int i = 0; i < widget.event.getQrCodeList.length; i++)
            {
              if (widget.event.getQrCodeList[i] == barcode.code)
                {
                  {
                    setState(() {
                      this.barcode = barcode;
                      isQrCodeValid = true;
                      text = 'This is a valid qrCode';
                    }),
                  }
                }
            },
          if (isQrCodeValid == false)
            {
              setState(() {
                this.barcode = barcode;
                text = 'This is a NOT a valid qrCode';
              })
            },
          Timer(Duration(seconds: 4), () {
            setState(() {
              //isQrCodeValid = false;
              text = 'Scan a Qr code please';
            });
          })
        });
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQrViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
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
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
