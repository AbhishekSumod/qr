import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japfood/CartProvider.dart';
import 'package:japfood/QrCodePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ), // Provide the CartProvider instance
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QReat',
        home: QrCodePage(), // Set QrCodePage as the initial screen
      ),
    );
  }
}
