import 'package:cardemo/cameraimageupload.dart';
import 'package:cardemo/helpers/color.dart';
import 'package:cardemo/helpers/cgupload.dart';
import 'package:cardemo/helpers/getCurrentPosition.dart';
import 'package:cardemo/helpers/responsive.dart';
import 'package:cardemo/submit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:html' as html;

class SelfInspection extends StatefulWidget {
  @override
  State<SelfInspection> createState() => _SelfInspectionState();
}

class _SelfInspectionState extends State<SelfInspection> {
  // Only camera
  DateTime? _timestamp;
  double? _latitude;
  double? _longitude;
  String frontSide = "";
  String frontSideTimeStamp = "";
  String frontSideLocation = "";
  String frontRightHandSide = "";
  String frontRightHandSideTimeStamp = "";
  String frontRightHandSideLocation = "";
  String driverSide = "";
  String driverSideTimeStamp = "";
  String driverSideLocation = "";
  String rearRightHandSide = "";
  String rearRightHandSideTimeStamp = "";
  String rearRightHandSideLocation = "";
  String rearSide = "";
  String rearSideTimeStamp = "";
  String rearSideLocatiom = "";
  String rearLeftHandSide = "";
  String rearLeftHandSideTimeStamp = "";
  String rearLeftHandSideLocation = "";
  String passengerSide = "";
  String passengerSideTimeStamp = "";
  String passengerSideLocation = "";
  String frontLeftHandSide = "";
  String frontLeftHandSideTimeStamp = "";
  String frontLeftHandSideLocation = "";
  String engineCompart = "";
  String engineCompartTimeStamp = "";
  String engineCompartLocation = "";
  String chassisNo = "";
  String chassisNoTimeStamp = "";
  String chassisNoLocation = "";
  String odometerCar = "";
  String odometerCarTimeStamp = "";
  String odometerCarLocation = "";

  // Camera + Gallery
  String regCert = "";
  String regCertTimeStamp = "";
  String regCertLocation = "";
  String inspectionCert = "";
  String inspectionCertTimeStamp = "";
  String inspectionCertLocation = "";
  String optional1 = "";
  String optional1TimeStamp = "";
  String optional1Location = "";
  String optional2 = "";
  String optional2TimeStamp = "";
  String optional2Location = "";

  //Submit
  bool showSubmit = false;

  Future<String?> fetchJwtToken() async {
    final String authApiUrl =
        "YOUR_AUTH_API_ENDPOINT_HERE"; // Replace with your JWT token endpoint.

    final request = html.HttpRequest();
    request
      ..open('POST', authApiUrl) // Assuming POST; replace if needed.
      ..setRequestHeader('Content-Type', 'application/json')
      // Add other headers or body data if necessary for your auth endpoint
      ..send();

    await request.onLoadEnd
        .firstWhere((event) => request.readyState == html.HttpRequest.DONE);

    if (request.status == 200) {
      if (request.responseText != null) {
        final responseMap = json.decode(request
            .responseText!); // Using the "!" to tell Dart we're sure it's not null here.
        return responseMap["token"];
      } else {
        print('Response text is null');
        return null;
      }
    } else {
      print('Failed to fetch JWT token. Status: ${request.status}');
      return null;
    }
  }

  Future<html.HttpRequest> sendImageToApi(String image, String jwtToken) async {
    final String apiUrl = "YOUR_API_ENDPOINT_HERE";

    final requestData = jsonEncode({'image': image});

    final request = html.HttpRequest();
    request
      ..open('POST', apiUrl)
      ..setRequestHeader('Content-Type', 'application/json')
      ..setRequestHeader('Authorization', 'Bearer $jwtToken')
      ..send(requestData);

    await request.onLoadEnd
        .firstWhere((event) => request.readyState == html.HttpRequest.DONE);

    return request;
  }

  Future<void> _submitImages() async {
    List<String> images = [
      rearSide,
      rearLeftHandSide,
      passengerSide
    ]; //... and other images

    String? jwtToken = await fetchJwtToken();
    if (jwtToken == null) {
      print("Failed to fetch JWT token!");
      return;
    }

    for (String imageUrl in images) {
      final response = await sendImageToApi(imageUrl, jwtToken);

      if (response.status == 200) {
        // Image upload successful for this image
      } else {
        print(
            'Error uploading image: $imageUrl with status: ${response.status}');
      }
    }
  }

  void disablesubmitposp() {
    if (regCert != '' &&
        inspectionCert != '' &&
        frontSide != '' &&
        frontRightHandSide != '' &&
        driverSide != '' &&
        rearRightHandSide != '' &&
        rearSide != '' &&
        rearLeftHandSide != '' &&
        passengerSide != '' &&
        frontLeftHandSide != '' &&
        engineCompart != '' &&
        chassisNo != '' &&
        odometerCar != '') {
      setState(() {
        showSubmit = true;
      });
    }
  }

  // Future<img.BitmapFont> loadFont(String path) async {
  //   final ByteData data = await rootBundle.load(path);
  //   final List<int> bytes = data.buffer.asUint8List();
  //   return img.BitmapFont.fromBytes(bytes);
  // }

  void disablesubmitcust() {
    if (regCert != '' &&
        frontSide != '' &&
        frontRightHandSide != '' &&
        driverSide != '' &&
        rearRightHandSide != '' &&
        rearSide != '' &&
        rearLeftHandSide != '' &&
        passengerSide != '' &&
        frontLeftHandSide != '' &&
        engineCompart != '' &&
        chassisNo != '' &&
        odometerCar != '') {
      setState(() {
        showSubmit = true;
      });
    }
  }

  void disablesubmit() {
    // if (widget.iscust == false ||
    //     widget.ic != "1" ||
    //     widget.ic != "14" ||
    //     widget.ic != "19") {
    //   disablesubmitcust();
    // } else {
    //   disablesubmitposp();
    // }
  }

  void updateRegCert(path, time, location) {
    setState(() {
      regCert = path;
      regCertTimeStamp = time;
      regCertLocation = location;
    });
    disablesubmit();
    setState(() {
      showSubmit = true;
    });
  }

  void updateInspectionCert(path, time, location) {
    setState(() {
      inspectionCert = path;
      inspectionCertTimeStamp = time;
      inspectionCertLocation = location;
    });
    disablesubmit();
  }

  void updateOptional1(path, time, location) {
    setState(() {
      optional1 = path;
      optional1TimeStamp = time;
      optional1Location = location;
    });
  }

  void updateOptional2(path, time, location) {
    setState(() {
      optional2 = path;
      optional2TimeStamp = time;
      optional2Location = location;
    });
  }

  void updateSingleImage(idx, path, time, location) {
    if (idx == 0) {
      setState(() {
        frontSide = path;
        frontSideTimeStamp = time;
        frontSideLocation = location;
      });
    } else if (idx == 1) {
      setState(() {
        frontRightHandSide = path;
        frontRightHandSideTimeStamp = time;
        frontRightHandSideLocation = location;
      });
    } else if (idx == 2) {
      setState(() {
        driverSide = path;
        driverSideTimeStamp = time;
        driverSideLocation = location;
      });
    } else if (idx == 3) {
      setState(() {
        rearRightHandSide = path;
        rearRightHandSideTimeStamp = time;
        rearRightHandSideLocation = location;
      });
    } else if (idx == 4) {
      setState(() {
        rearSide = path;
        rearSideTimeStamp = time;
        rearSideLocatiom = location;
      });
    } else if (idx == 5) {
      setState(() {
        rearLeftHandSide = path;
        rearLeftHandSideTimeStamp = time;
        rearLeftHandSideLocation = location;
      });
    } else if (idx == 6) {
      setState(() {
        passengerSide = path;
        passengerSideTimeStamp = time;
        passengerSideLocation = location;
      });
    } else if (idx == 7) {
      setState(() {
        frontLeftHandSide = path;
        frontLeftHandSideTimeStamp = time;
        frontLeftHandSideLocation = location;
      });
    } else if (idx == 8) {
      setState(() {
        engineCompart = path;
        engineCompartTimeStamp = time;
        engineCompartLocation = location;
      });
    } else if (idx == 9) {
      setState(() {
        chassisNo = path;
        chassisNoTimeStamp = time;
        chassisNoLocation = location;
      });
    } else if (idx == 10) {
      setState(() {
        odometerCar = path;
        odometerCarTimeStamp = time;
        odometerCarLocation = location;
      });
    }
    disablesubmit();
  }

  // Future<ui.Image> drawText(String text) async {
  //   final recorder = ui.PictureRecorder();
  //   final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(300, 50)));  // Adjust the size as required
  //
  //   final style = TextStyle(
  //     color: Colors.white,
  //     fontSize: 14,
  //   );
  //
  //   final painter = TextPainter(
  //     text: TextSpan(text: text, style: style),
  //     textDirection: TextDirection.ltr,
  //   );
  //
  //   painter.layout();
  //   painter.paint(canvas, Offset(0, 0));
  //
  //   return recorder.endRecording().toImage(300, 50);  // Adjust the size as required
  // }

  void updateCameraImages(imageData) {
    setState(() {
      frontSide = imageData[0]["imgPath"];
      frontSideTimeStamp = imageData[0]["timestamp"];
      frontSideLocation = imageData[0]["location"];

      frontRightHandSide = imageData[1]["imgPath"];
      frontRightHandSideTimeStamp = imageData[1]["timestamp"];
      frontRightHandSideLocation = imageData[1]["location"];

      driverSide = imageData[2]["imgPath"];
      driverSideTimeStamp = imageData[2]["timestamp"];
      driverSideLocation = imageData[2]["location"];

      rearRightHandSide = imageData[3]["imgPath"];
      rearRightHandSideTimeStamp = imageData[3]["timestamp"];
      rearRightHandSideLocation = imageData[3]["location"];

      rearSide = imageData[4]["imgPath"];
      rearSideTimeStamp = imageData[4]["timestamp"];
      rearSideLocatiom = imageData[4]["location"];

      rearLeftHandSide = imageData[5]["imgPath"];
      rearLeftHandSideTimeStamp = imageData[5]["timestamp"];
      rearLeftHandSideLocation = imageData[5]["location"];

      passengerSide = imageData[6]["imgPath"];
      passengerSideTimeStamp = imageData[6]["timestamp"];
      passengerSideLocation = imageData[6]["location"];

      frontLeftHandSide = imageData[7]["imgPath"];
      frontLeftHandSideTimeStamp = imageData[7]["timestamp"];
      frontLeftHandSideLocation = imageData[7]["location"];

      engineCompart = imageData[8]["imgPath"];
      engineCompartTimeStamp = imageData[8]["timestamp"];
      engineCompartLocation = imageData[8]["location"];

      chassisNo = imageData[9]["imgPath"];
      chassisNoTimeStamp = imageData[9]["timestamp"];
      chassisNoLocation = imageData[9]["location"];

      odometerCar = imageData[10]["imgPath"];
      odometerCarTimeStamp = imageData[10]["timestamp"];
      odometerCarLocation = imageData[10]["location"];
    });
    disablesubmit();
  }

  // static String getFileSizeString({@required int bytes, int decimals = 0}) {
  //   const suffixes = ["b", "kb", "mb", "gb", "tb"];
  //   var i = (log(bytes) / log(1024)).floor();
  //   return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  // }

  final ImagePicker _picker = ImagePicker();

  dynamic showUploadOptions(Function updateData) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        alignment: Alignment.center,
        content: Container(
          height: ResHeight(200),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('Camera'),
                  onPressed: () async {
                    Get.back();
                    final XFile? photo = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 30,
                        maxHeight: 1280,
                        maxWidth: 720);
                    File image = File('photo');
                    // Or any other way to get a File instance.
                    //  print(getFilesizeString(bytes: photo.lengthSync());
                    // var decodedImage =
                    //     await decodeImageFromList(image.readAsBytesSync());
                    // print(decodedImage.width);
                    // print(decodedImage.height);
                    // final size = ImageSizeGetter.getSize(FileInput(image));
                    // print('jpg = $size');

                    var location = await determinePosition();
                    DateTime currentPhoneDate = DateTime.now();
                    updateData(photo?.path, currentPhoneDate.toString(),
                        "${location.latitude};${location.longitude}");
                  },
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.all(yellow),
                  ),
                ),
                SizedBox(
                  height: ResHeight(20),
                ),
                ElevatedButton(
                  child: const Text('Gallery'),
                  onPressed: () async {
                    Get.back();

                    final XFile? photo = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 30,
                        maxHeight: 1280,
                        maxWidth: 720);
                    var location = await determinePosition();
                    DateTime currentPhoneDate = DateTime.now();
                    updateData(photo?.path, currentPhoneDate.toString(),
                        "${location.latitude};${location.longitude}");
                  },
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.all(yellow),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            alignment: Alignment.center,
            title: Text("Are you sure you want to go back?"),
            content: Container(
              height: ResHeight(80),
              child: Center(
                child: Text(
                    "Going back will revert all your progress done till now"),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Yes"),
                  )),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("No"),
                  ))
            ],
          ),
        );
        return false;
      },
      child: SafeArea(
          child: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: white,
              elevation: 0,
              title: Text(
                "Upload images",
                style: TextStyle(
                    color: Colors.blue[900], fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(children: [
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                      child: Text(
                    "Take the vehicle image using camera",
                    style: TextStyle(fontSize: 16, color: Colors.blue[900]),
                  )),
                  Center(
                    child: ElevatedButton(
                      child: odometerCar == ""
                          ? Text('Take Images',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blue[900]))
                          : Text('Retake Images',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blue[900])),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            alignment: Alignment.center,
                            title: Text("Image Upload Instructions",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blue[900])),
                            content: Container(
                              height: ResHeight(300),
                              child: const Center(
                                child: Text(
                                    "The photos to be captured in proper day-light and open area only. Please do not click the photos in covered area such as garages, underground & parking areas etc."),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      backgroundColor:
                                          MaterialStateProperty.all(yellow)),
                                  onPressed: () async {
                                    print("doneeeeeeeee");
                                    Get.back();
                                    Get.to(CameraImageUpload(
                                      updateCameraImages,
                                      false,
                                      "",
                                      () {},
                                      0,
                                    ));
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Continue",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF0D47A1))),
                                  )),
                            ],
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(yellow),
                      ),
                    ),
                  ),
                  odometerCar != ""
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Front Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[900]),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Front Side",
                                          updateSingleImage,
                                          0,
                                        ));
                                      },
                                      child: Text("Retake",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF0D47A1))))
                                ],
                              ),
                              Image.network(frontSide),

                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Front RightHand Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Front RightHand Side",
                                          updateSingleImage,
                                          1,
                                        ));
                                      },
                                      child: Text("Retake",
                                          style: TextStyle(
                                              color: Color(0xFF0D47A1))))
                                ],
                              ),
                              Image.network(frontRightHandSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Driver Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Driver Side",
                                          updateSingleImage,
                                          2,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(driverSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rear RightHand Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Rear RightHand Side",
                                          updateSingleImage,
                                          3,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(rearRightHandSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rear Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Rear Side",
                                          updateSingleImage,
                                          4,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(rearSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rear LeftHand Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Rear LeftHand Side",
                                          updateSingleImage,
                                          5,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(rearLeftHandSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Passenger Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Passenger Side",
                                          updateSingleImage,
                                          6,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(passengerSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Front LeftHand Side",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Front LeftHand Side",
                                          updateSingleImage,
                                          7,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(frontLeftHandSide),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Engine Compart",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Engine Compart",
                                          updateSingleImage,
                                          8,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(engineCompart),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Chassis Number",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D47A1)),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Chassis Number",
                                          updateSingleImage,
                                          9,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(chassisNo),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Odometer Car",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(yellow),
                                        elevation: MaterialStateProperty.all(0),
                                      ),
                                      onPressed: () {
                                        Get.to(CameraImageUpload(
                                          () {},
                                          true,
                                          "Odometer Car",
                                          updateSingleImage,
                                          10,
                                        ));
                                      },
                                      child: Text(
                                        "Retake",
                                        style:
                                            TextStyle(color: Color(0xFF0D47A1)),
                                      ))
                                ],
                              ),
                              Image.network(odometerCar),
                              // Stack(
                              //   children: [
                              //     Image.network(odometerCar), // or any other method you use to display the image
                              //     Positioned(
                              //       bottom: 60,
                              //       left: 10,
                              //       child: Text(
                              //         timestamp.toIso8601String(),
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           color: Colors.white,
                              //           backgroundColor: Colors.black.withOpacity(0.6),
                              //         ),
                              //       ),
                              //     ),
                              //     Positioned(
                              //       bottom: 10,
                              //       left: 10,
                              //       child: Text(
                              //         "Lat: $latitude, Long: $longitude",
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           color: Colors.white,
                              //           backgroundColor: Colors.black.withOpacity(0.6),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 30,
                  ),
                  // Center(
                  //   child: Text(
                  //     "Upload/Click required Documents/Images",
                  //     style: TextStyle(fontSize: 16,color: Color(0xFF0D47A1) ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        // child: Column(
                        //   children: [
                        //  Cgupload(
                        //         'Inspection Certificate',
                        //         inspectionCert,
                        //         updateInspectionCert,
                        //         showUploadOptions),
                        //
                        //
                        //
                        //     //   padding: EdgeInsets.symmetric(horizontal: 10),
                        //     //   child: Center(
                        //     //     child: Text(
                        //     //       "Some IC Msg here random text random text radom text random text",
                        //     //       style: TextStyle(fontSize: 16),
                        //     //     ),
                        //     //   ),
                        //     // ),
                        //     // SizedBox(
                        //     //   height: 14,
                        //     // ),
                        //     Cgupload('Optional 1', optional1, updateOptional1,
                        //         showUploadOptions),
                        //     SizedBox(
                        //       height: 14,
                        //     ),
                        //     Cgupload('Optional 2', optional2, updateOptional2,
                        //         showUploadOptions),
                        //   ],
                        // ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  odometerCar != "" && odometerCar.isNotEmpty
                      ? Center(
                          child: ElevatedButton(
                            child: Text(
                              "Submit Form",
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF0D47A1)),
                            ),
                            onPressed: () async {
                              // your onPressed logic here
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.all(yellow),
                            ),
                          ),
                        )
                      : Container()

                  // child: ElevatedButton(
                  //   child: Text(
                  //     "Submit Form",
                  //     style: TextStyle(fontSize: 16,color: Color(0xFF0D47A1) ),
                  //   ),
                  //   onPressed: () async {
                  //     setState(() {
                  //       uploading = true;
                  //     });
                  //
                  //
                  //
                  //       print("//////////////////////");
                  //       print(frontSide);
                  //       print(regCert);
                  //       print(odometerCar);
                  //       // submitInspection(
                  //       //     frontSide: frontSide,
                  //       //     frontSideTimeStamp: frontSideTimeStamp,
                  //       //     frontSideLocation: frontSideLocation,
                  //       //     frontRightHandSide: frontRightHandSide,
                  //       //     frontRightHandSideTimeStamp:
                  //       //     frontRightHandSideTimeStamp,
                  //       //     frontRightHandSideLocation:
                  //       //     frontRightHandSideLocation,
                  //       //     driverSide: driverSide,
                  //       //     driverSideTimeStamp: driverSideTimeStamp,
                  //       //     driverSideLocation: driverSideLocation,
                  //       //     rearRightHandSide: rearRightHandSide,
                  //       //     rearRightHandSideTimeStamp:
                  //       //     rearRightHandSideTimeStamp,
                  //       //     rearRightHandSideLocation:
                  //       //     rearRightHandSideLocation,
                  //       //     rearSide: rearSide,
                  //       //     rearSideTimeStamp: rearSideTimeStamp,
                  //       //     rearSideLocatiom: rearSideLocatiom,
                  //       //     rearLeftHandSide: rearLeftHandSide,
                  //       //     rearLeftHandSideTimeStamp:
                  //       //     rearLeftHandSideTimeStamp,
                  //       //     rearLeftHandSideLocation:
                  //       //     rearLeftHandSideLocation,
                  //       //     passengerSide: passengerSide,
                  //       //     passengerSideTimeStamp:
                  //       //     passengerSideTimeStamp,
                  //       //     passengerSideLocation:
                  //       //     passengerSideLocation,
                  //       //     frontLeftHandSide: frontLeftHandSide,
                  //       //     frontLeftHandSideTimeStamp:
                  //       //     frontLeftHandSideTimeStamp,
                  //       //     frontLeftHandSideLocation:
                  //       //     frontLeftHandSideLocation,
                  //       //     engineCompart: engineCompart,
                  //       //     engineCompartTimeStamp:
                  //       //     engineCompartTimeStamp,
                  //       //     engineCompartLocation:
                  //       //     engineCompartLocation,
                  //       //     chassisNo: chassisNo,
                  //       //     chassisNoTimeStamp: chassisNoTimeStamp,
                  //       //     chassisNoLocation: chassisNoLocation,
                  //       //     odometerCar: odometerCar,
                  //       //     odometerCarTimeStamp: odometerCarTimeStamp,
                  //       //     odometerCarLocation: odometerCarLocation,
                  //       //     regCert: regCert,
                  //       //     regCertTimeStamp: regCertTimeStamp,
                  //       //     regCertLocation: regCertLocation,
                  //       //     inspectionCert: inspectionCert,
                  //       //     inspectionCertTimeStamp:
                  //       //     inspectionCertTimeStamp,
                  //       //     inspectionCertLocation:
                  //       //     inspectionCertLocation,
                  //       //     optional1: optional1,
                  //       //     optional1TimeStamp: optional1TimeStamp,
                  //       //     optional1Location: optional1Location,
                  //       //     optional2: optional2,
                  //       //     optional2TimeStamp: optional2TimeStamp,
                  //       //     optional2Location: optional2Location);
                  //
                  //   },
                  //   style: ButtonStyle(
                  //     elevation: MaterialStateProperty.all(0),
                  //     backgroundColor: MaterialStateProperty.all(yellow),
                  //   ),
                  // )
                  // : ElevatedButton(
                  // onPressed: () {},
                  // child: Text("Submit Form"),
                  // style: ButtonStyle(
                  //   elevation: MaterialStateProperty.all(0),
                  //   backgroundColor:
                  //   MaterialStateProperty.all(Colors.grey),
                  // )),
                ]),
              ),
            ),
          ),
          uploading
              ? Scaffold(
                  backgroundColor: Color.fromARGB(122, 0, 0, 0),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: yellow,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Uploading Images...",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                )
              : Container()
        ],
      )),
    );
  }
}
