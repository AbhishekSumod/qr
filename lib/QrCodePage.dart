import 'package:flutter/material.dart';
import 'package:japfood/HomeScreen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Codes'),
      ),
      body: ListView(
        children: [
          buildQrCode(context, '1', 'Table 1'),
          SizedBox(height: 20),
          buildQrCode(context, '2', 'Table 2'),
          SizedBox(height: 20),
          buildQrCode(context, '3', 'Table 3'),
        ],
      ),
    );
  }

  Widget buildQrCode(BuildContext context, String data, String label) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(qrCodeValue: data),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 150.0,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
