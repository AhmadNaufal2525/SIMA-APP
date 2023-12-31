import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:sima_app/src/datasource/aset_remote_datasource.dart';

class QRScannerPengembalianScreen extends StatefulWidget {
  final String username;
  final String token;
  const QRScannerPengembalianScreen(
      {super.key, required this.username, required this.token});

  @override
  State<QRScannerPengembalianScreen> createState() =>
      _QRScannerPengembalianScreenState();
}

class _QRScannerPengembalianScreenState
    extends State<QRScannerPengembalianScreen> {
  bool isScanCompleted = false;
  String tagNum = '';
  final AsetRemoteDataSource asetDataSource = AsetRemoteDataSource();

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Qr Scanner Pengembalian',
          style: TextStyle(
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16).w,
        child: Column(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Letakkan QR Code di area',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  'Scanning akan dimulai secara otomatis',
                  style: TextStyle(color: Colors.black54, fontSize: 16.sp),
                ),
              ],
            )),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  MobileScanner(
                    allowDuplicates: true,
                    onDetect: (barcode, args) {
                      if (!isScanCompleted) {
                        isScanCompleted = true;
                        String code = barcode.rawValue ?? '---';
                        setState(() {
                          tagNum = code;
                        });
                        asetDataSource.pengembalianData(
                            context, tagNum, widget.username, widget.token);
                      }
                    },
                  ),
                  QRScannerOverlay(
                    borderColor: Colors.white,
                    overlayColor: Colors.white10,
                    scanAreaSize: Size(220.w, 220.h),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Developed By Sucofindo',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.sp,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
