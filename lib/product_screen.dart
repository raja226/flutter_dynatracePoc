import 'package:flutter/material.dart';
import 'package:flutter_dynatrace_poc/constants.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product  Page"),backgroundColor: Colors.blueGrey,),
    );  }
}