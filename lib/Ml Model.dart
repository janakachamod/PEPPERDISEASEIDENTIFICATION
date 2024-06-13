import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'component/constants.dart';
import 'component/custom_outline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MlModel extends StatefulWidget {
  @override
  State<MlModel> createState() => _MlModel();
}

class _MlModel extends State<MlModel> {
  String? result;
  final picker = ImagePicker();
  File? img;
  var url =
      "http://192.168.43.122:5000/predictApi"; // Ensure this URL is correct and accessible

  Future pickImage() async {
    try {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          img = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future captureImage() async {
    try {
      final capturedFile = await picker.getImage(
        source: ImageSource.camera,
      );
      if (capturedFile != null) {
        setState(() {
          img = File(capturedFile.path);
        });
      } else {
        print('No image captured.');
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future upload() async {
    if (img == null) {
      print('No image selected for upload.');
      return;
    }

    try {
      final request = http.MultipartRequest("POST", Uri.parse(url));
      final headers = {"Content-Type": "multipart/form-data"};
      request.files.add(
        http.MultipartFile(
            'fileup', img!.readAsBytes().asStream(), img!.lengthSync(),
            filename: img!.path.split('/').last),
      );
      request.headers.addAll(headers);

      final myRequest = await request.send();
      final res = await http.Response.fromStream(myRequest);

      if (myRequest.statusCode == 200) {
        final resJson = jsonDecode(res.body);
        print("response here: $resJson");
        setState(() {
          result = resJson['prediction'];
        });

        // Check if the prediction is "Pepper Leaf Bacterial Spot" and navigate to Threat page if true
        if (result == 'Pepper Leaf Bacterial Spot') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThreatPage()),
          );
        }
      } else {
        print("Error ${myRequest.statusCode}: ${res.body}");
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Constants.kBlackColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Constants.kPinkColor,
        title: Text('Pepper Disease Prediction'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.1,
                left: -88,
                child: Container(
                  height: 166,
                  width: 166,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Constants.kPinkColor,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 200,
                      sigmaY: 200,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.3,
                right: -100,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Constants.kGreenColor,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 200,
                      sigmaY: 200,
                    ),
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    CustomOutline(
                      strokeWidth: 4,
                      radius: screenWidth * 0.8,
                      padding: const EdgeInsets.all(4),
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.8,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constants.kPinkColor,
                          Constants.kPinkColor.withOpacity(0),
                          Constants.kGreenColor.withOpacity(0.1),
                          Constants.kGreenColor
                        ],
                        stops: const [
                          0.2,
                          0.4,
                          0.6,
                          1,
                        ],
                      ),
                      child: Center(
                        child: img == null
                            ? Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomLeft,
                                    image: AssetImage(''),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomLeft,
                                    image: FileImage(img!),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Center(
                      child: img == null
                          ? Text(
                              'THE MODEL HAS NOT BEEN PREDICTED',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Constants.kWhiteColor.withOpacity(0.85),
                                fontSize: screenHeight <= 667 ? 18 : 34,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Text(
                              'Result from Model ML: $result',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Constants.kWhiteColor.withOpacity(0.85),
                                fontSize: screenHeight <= 667 ? 18 : 34,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    CustomOutline(
                      strokeWidth: 3,
                      radius: 20,
                      padding: const EdgeInsets.all(3),
                      width: 160,
                      height: 38,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Constants.kPinkColor, Constants.kGreenColor],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Constants.kPinkColor.withOpacity(0.5),
                              Constants.kGreenColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white12,
                            ),
                          ),
                          onPressed: pickImage,
                          child: Text(
                            'Pick Image Here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomOutline(
                      strokeWidth: 3,
                      radius: 20,
                      padding: const EdgeInsets.all(3),
                      width: 160,
                      height: 38,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Constants.kPinkColor, Constants.kGreenColor],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Constants.kPinkColor.withOpacity(0.5),
                              Constants.kGreenColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white12,
                            ),
                          ),
                          onPressed: captureImage,
                          child: Text(
                            'Capture Image',
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomOutline(
                      strokeWidth: 3,
                      radius: 20,
                      padding: const EdgeInsets.all(3),
                      width: 160,
                      height: 38,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Constants.kPinkColor, Constants.kGreenColor],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Constants.kPinkColor.withOpacity(0.5),
                              Constants.kGreenColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white12,
                            ),
                          ),
                          onPressed: upload,
                          child: Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment for Bacterial Spot Disease'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Threat detected: Pepper Leaf Bacterial Spot',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bacterial spot is a common disease affecting pepper plants. It can cause significant damage to the leaves and fruits, leading to reduced yield. Effective treatment includes the following steps:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            BulletPoint(text: 'Remove infected plants to prevent spread.'),
            BulletPoint(text: 'Apply copper-based bactericides regularly.'),
            BulletPoint(
                text:
                    'Ensure proper spacing between plants to improve air circulation.'),
            BulletPoint(
                text: 'Avoid overhead watering to reduce leaf wetness.'),
            BulletPoint(
                text:
                    'Practice crop rotation to avoid pathogen buildup in the soil.'),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.brightness_1, size: 8, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
