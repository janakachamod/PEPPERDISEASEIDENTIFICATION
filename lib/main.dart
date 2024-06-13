import 'package:flutter/material.dart';
import 'package:pepperdisesesidentification/Ml%20Model.dart';

void main() {
  runApp(const MLAPP());
}

class MLAPP extends StatelessWidget {
  const MLAPP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MlModel());
  }
}
