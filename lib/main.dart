
import 'package:cardemo/SurveyScreen.dart';
import 'package:cardemo/otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardemo/helpers/routeobserver.dart';

import 'package:flutter/services.dart';


import 'DynamicDropdown.dart';
import 'VehicleImageCapture.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCj1qGhCQkAVwfciZ4m7EtCRfMNZPQsyWg",
            authDomain: "fir-ffb17.firebaseapp.com",
            projectId: "fir-ffb17",
            storageBucket: "fir-ffb17.appspot.com",
            messagingSenderId: "671277342571",
            appId: "1:671277342571:web:dfd03c005cf8834f05362e",
            measurementId: "G-7TR6JYMBT4"
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // You might want to show an error dialog or handle this gracefully
  }

  runApp(MyApp());
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Damage detection',
      theme: ThemeData(
        primaryColor: Color(0xFF00008B),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(0xFF00008B, {
            50: Color(0xFFE6E6FA),
            100: Color(0xFFCDCDFF),
            200: Color(0xFFB4B4FF),
            300: Color(0xFF9A9AFF),
            400: Color(0xFF8080FF),
            500: Color(0xFF6666FF),
            600: Color(0xFF4C4CFF),
            700: Color(0xFF3333FF),
            800: Color(0xFF1A1AFF),
            900: Color(0xFF00008B),
            1000:Color(0xFF1A237E)
          }),
          accentColor: Colors.yellow,
          brightness: Brightness.light,
        ),
      ),
      home: SurveyScreen(),
      navigatorObservers: [routeObserver],
        getPages: [
        GetPage(name: '/upload', page: () => VehicleImageCapture(make: '', model: '',))
        ]
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 70),

              Text(
                'Please Enter your phone number',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    // Circular border
                    borderSide: BorderSide(
                        color: Colors.blue[900]!, width: 2), // Dark blue border
                  ),
                  prefix: Text("+91  "), // +91 Prefix
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              FloatingActionButton.extended(
                label: Text('Enter', style: TextStyle(color: Colors.blue[900])),
                backgroundColor: Colors.yellow,
                onPressed: () {
                  Get.to(otpenter());
                },
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue[900]!, width: 2.0), // Dark blue border
                  borderRadius: BorderRadius.circular(30.0), // Rounded border
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}





class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text(
                'Your claim has been successfully registered!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// class CameraImageUploadQQ extends StatefulWidget {
//   @override
//   _CameraImageUploadStateQQ createState() => _CameraImageUploadStateQQ();
// }
//
// class _CameraImageUploadStateQQ extends State<CameraImageUploadQQ> {
//   List<String> imageTitles = [
//     "FrontSide", "FrontRightHandSide", "DriverSide",
//     "RearRightHandSide", "RearSide", "RearLeftHandSide",
//     "PassengerSide", "FrontLeftHandSide", "EngineCompart",
//     "ChassisNo", "OdometerCar"
//   ];
//
//   int currentIndex = 0;
//   List<html.File> selectedImages = [];
//   List<Uint8List> imagePreviews = [];
//   bool uploading = false;
//
//   // This function will be used to capture images using the camera (replace with camera library for Flutter Web)
//   Future<void> captureImage() async {
//     // This simulates capturing an image from the camera. Replace it with actual camera capture logic.
//     var image = await ImagePickerWeb.getImageAsFile(); // Replace with camera capture logic
//
//     if (image != null) {
//       Uint8List imageBytes = await _readFileAsBytes(image);
//       setState(() {
//         selectedImages.add(image);
//         imagePreviews.add(imageBytes);
//
//         // If all images are captured, show preview
//         if (currentIndex < imageTitles.length - 1) {
//           currentIndex++;
//         }
//       });
//     }
//   }
//
//   Future<Uint8List> _readFileAsBytes(html.File file) {
//     final reader = html.FileReader();
//     final completer = Completer<Uint8List>();
//
//     reader.onLoadEnd.listen((event) {
//       completer.complete(reader.result as Uint8List);
//     });
//
//     reader.onError.listen((event) {
//       completer.completeError(event);
//     });
//
//     reader.readAsArrayBuffer(file);
//     return completer.future;
//   }
//
//   Future<void> uploadImages() async {
//     setState(() {
//       uploading = true;
//     });
//
//     final apiUrl = 'http://164.52.202.251/fw_damage/create_fw_claim'; // Replace with your actual server URL
//
//     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//
//     // Add static form data fields
//     Map<String, dynamic> staticFormData = _getStaticFormData();
//     staticFormData.forEach((key, value) {
//       request.fields[key] = value.toString();
//     });
//
//     // Add images to the request
//     for (var i = 0; i < selectedImages.length; i++) {
//       var file = selectedImages[i];
//
//       // Read the file as Uint8List using the _readFileAsBytes function
//       Uint8List fileBytes = await _readFileAsBytes(file);
//
//       // Create multipart file from bytes
//       var multipartFile = http.MultipartFile.fromBytes(
//         'images[]',
//         fileBytes,
//         filename: file.name,
//         contentType: MediaType('image', 'jpeg'),
//       );
//
//       request.files.add(multipartFile);
//     }
//
//     var response = await request.send();
//
//     if (response.statusCode == 200) {
//       print('Images and data uploaded successfully');
//     } else {
//       print('Failed to upload images and data');
//     }
//
//     setState(() {
//       uploading = false;
//     });
//   }
//
// // Method to read file as bytes
//
// // Your static form data method
//   Map<String, dynamic> _getStaticFormData() {
//     return {
//       "policy_number": "POL123456",
//       "full_name": "John Doe",
//       "loss_type": "Accident",
//       "claim_number": "CLM789012",
//       "permanent_address_line1": "123 Main St",
//       "city_district": "Metropolis",
//       "select_city": "Metropolis",
//       "state": "State",
//       "location": "State",
//       "country": "India",
//       "pincode": "123456",
//       "mobile": "9876543210",
//       "email": "johndoe@example.com",
//       "date_of_registration": "2022-01-01",
//       "reg_date": "2022-01-01",
//       "vehicle_number": "MH01AB1234",
//       "engine_number": "ENG123456",
//       "chassis_number": "CHS789012",
//       "make": "Maruti",
//       "select_model": "Swift",
//       "odometer": "50000",
//       "driver_full_name": "Jane Doe",
//       "gender": "Female",
//       "date_of_birth": "1990-01-01",
//       "driving_license_number": "DL987654",
//       "license_issuing_authority": "RTO Mumbai",
//       "license_expiry_date": "2030-01-01",
//       "license_for_vehicle_type": "LMV",
//       "temporary_license": "false",
//       "relation_with_insured": "Spouse",
//       "employment_duration": "5",
//       "under_influence": "false",
//       "date_of_accident": "2024-09-10",
//       "time_of_accident": "14:30",
//       "speed_of_vehicle": "40",
//       "number_of_occupants": "2",
//       "incident_location": "Near City Center",
//       "location_of_accident": "Near City Center",
//       "description_of_accident": "Minor collision at intersection",
//       "reported_to_police": "true",
//       "police_station_name": "Central Police Station",
//       "fir_number": "FIR123456",
//       "garage_name": "City Auto Garage",
//       "garage_contact_person": "Mike Mechanic",
//       "garage_address": "456 Service Road, Metropolis",
//       "garage_phone_number": "9876543210",
//       "declaration_date": DateTime.now().toIso8601String(),
//       "declaration_place": "Metropolis",
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Capture ${imageTitles[currentIndex]}"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Current Image: ${imageTitles[currentIndex]}'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: captureImage, // Capture the next image
//               child: Text('Capture ${imageTitles[currentIndex]}'),
//             ),
//             SizedBox(height: 20),
//
//             // Preview all images if available
//             if (imagePreviews.isNotEmpty) ...[
//               Text('Image Previews:'),
//               Container(
//                 height: 200,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: imagePreviews.length,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       margin: EdgeInsets.all(8),
//                       child: Image.memory(
//                         imagePreviews[index],
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//
//             // Show submit button if all images are captured
//             if (currentIndex == imageTitles.length - 1 && selectedImages.length == imageTitles.length)
//               ElevatedButton(
//                 onPressed: uploadImages,
//                 child: Text('Submit Images'),
//               ),
//
//             // Loader when uploading images
//             if (uploading) CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }
// class SelfInspection extends StatefulWidget {
//   @override
//   State<SelfInspection> createState() => _SelfInspectionState();
// }
//
// class _SelfInspectionState extends State<SelfInspection> {
//   // Only camera
//   DateTime? _timestamp;
//   double? _latitude;
//   double? _longitude;
//   String frontSide = "";
//   String frontSideTimeStamp = "";
//   String frontSideLocation = "";
//   String frontRightHandSide = "";
//   String frontRightHandSideTimeStamp = "";
//   String frontRightHandSideLocation = "";
//   String driverSide = "";
//   String driverSideTimeStamp = "";
//   String driverSideLocation = "";
//   String rearRightHandSide = "";
//   String rearRightHandSideTimeStamp = "";
//   String rearRightHandSideLocation = "";
//   String rearSide = "";
//   String rearSideTimeStamp = "";
//   String rearSideLocatiom = "";
//   String rearLeftHandSide = "";
//   String rearLeftHandSideTimeStamp = "";
//   String rearLeftHandSideLocation = "";
//   String passengerSide = "";
//   String passengerSideTimeStamp = "";
//   String passengerSideLocation = "";
//   String frontLeftHandSide = "";
//   String frontLeftHandSideTimeStamp = "";
//   String frontLeftHandSideLocation = "";
//   String engineCompart = "";
//   String engineCompartTimeStamp = "";
//   String engineCompartLocation = "";
//   String chassisNo = "";
//   String chassisNoTimeStamp = "";
//   String chassisNoLocation = "";
//   String odometerCar = "";
//   String odometerCarTimeStamp = "";
//   String odometerCarLocation = "";
//
//   // Camera + Gallery
//   String regCert = "";
//   String regCertTimeStamp = "";
//   String regCertLocation = "";
//   String inspectionCert = "";
//   String inspectionCertTimeStamp = "";
//   String inspectionCertLocation = "";
//   String optional1 = "";
//   String optional1TimeStamp = "";
//   String optional1Location = "";
//   String optional2 = "";
//   String optional2TimeStamp = "";
//   String optional2Location = "";
//
//   //Submit
//   bool showSubmit = false;
//
//   Future<void> uploadImagesToApiForWeb(List<Uint8List> imageBytesList, List<String> fileNames) async {
//     final String apiUrl = 'http://192.168.1.9:8000/media/upload-images'; // Replace with your actual server URL
//
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//
//       for (int i = 0; i < imageBytesList.length && i < 12; i++) {
//         var file = http.MultipartFile.fromBytes(
//           'images', // Use 'images' as the field name for all images
//           imageBytesList[i],
//           filename: fileNames[i],
//           contentType: MediaType('image', 'jpeg'), // Adjust if you're using a different image format
//         );
//         request.files.add(file);
//       }
//
//       print('Sending request to upload ${request.files.length} images...');
//       var response = await request.send();
//       print('Response received. Status code: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         print('Images uploaded successfully');
//       } else {
//         print('Failed to upload images. Status code: ${response.statusCode}');
//         throw Exception('Failed to upload images');
//       }
//     } catch (e) {
//       print('Error uploading images: $e');
//       throw e;
//     }
//   }
//
//   Future<void> _pickAndSubmitImages() async {
//     setState(() {
//       uploading = true;
//     });
//
//     try {
//       // Pick images using FilePicker
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//         allowMultiple: true,
//       );
//
//       if (result != null && result.files.isNotEmpty) {
//         List<Uint8List> imageBytesList = [];
//         List<String> fileNames = [];
//
//         for (var file in result.files) {
//           if (file.bytes != null) {
//             imageBytesList.add(file.bytes!);
//             fileNames.add(file.name);
//           }
//         }
//
//         // Upload images to API
//         await uploadImagesToApiForWeb(imageBytesList, fileNames);
//         Get.snackbar('Success', 'All images uploaded successfully');
//       } else {
//         Get.snackbar('Error', 'No images selected');
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to upload images: $e');
//     } finally {
//       setState(() {
//         uploading = false;
//       });
//     }
//   }
//
//
//   void disablesubmitposp() {
//     if (regCert != '' &&
//         inspectionCert != '' &&
//         frontSide != '' &&
//         frontRightHandSide != '' &&
//         driverSide != '' &&
//         rearRightHandSide != '' &&
//         rearSide != '' &&
//         rearLeftHandSide != '' &&
//         passengerSide != '' &&
//         frontLeftHandSide != '' &&
//         engineCompart != '' &&
//         chassisNo != '' &&
//         odometerCar != '') {
//       setState(() {
//         showSubmit = true;
//       });
//     }
//   }
//
//
//
//   // Future<img.BitmapFont> loadFont(String path) async {
//   //   final ByteData data = await rootBundle.load(path);
//   //   final List<int> bytes = data.buffer.asUint8List();
//   //   return img.BitmapFont.fromBytes(bytes);
//   // }
//
//   void disablesubmitcust() {
//     if (regCert != '' &&
//         frontSide != '' &&
//         frontRightHandSide != '' &&
//         driverSide != '' &&
//         rearRightHandSide != '' &&
//         rearSide != '' &&
//         rearLeftHandSide != '' &&
//         passengerSide != '' &&
//         frontLeftHandSide != '' &&
//         engineCompart != '' &&
//         chassisNo != '' &&
//         odometerCar != '') {
//       setState(() {
//         showSubmit = true;
//       });
//     }
//   }
//
//   void disablesubmit() {
//     // if (widget.iscust == false ||
//     //     widget.ic != "1" ||
//     //     widget.ic != "14" ||
//     //     widget.ic != "19") {
//     //   disablesubmitcust();
//     // } else {
//     //   disablesubmitposp();
//     // }
//   }
//
//   void updateRegCert(path, time, location) {
//     setState(() {
//       regCert = path;
//       regCertTimeStamp = time;
//       regCertLocation = location;
//     });
//     disablesubmit();
//     setState(() {
//       showSubmit = true;
//     });
//   }
//
//   void updateInspectionCert(path, time, location) {
//     setState(() {
//       inspectionCert = path;
//       inspectionCertTimeStamp = time;
//       inspectionCertLocation = location;
//     });
//     disablesubmit();
//   }
//
//   void updateOptional1(path, time, location) {
//     setState(() {
//       optional1 = path;
//       optional1TimeStamp = time;
//       optional1Location = location;
//     });
//   }
//
//   void updateOptional2(path, time, location) {
//     setState(() {
//       optional2 = path;
//       optional2TimeStamp = time;
//       optional2Location = location;
//     });
//   }
//
//   void updateSingleImage(idx, path, time, location) {
//     if (idx == 0) {
//       setState(() {
//         frontSide = path;
//         frontSideTimeStamp = time;
//         frontSideLocation = location;
//       });
//     } else if (idx == 1) {
//       setState(() {
//         frontRightHandSide = path;
//         frontRightHandSideTimeStamp = time;
//         frontRightHandSideLocation = location;
//       });
//     } else if (idx == 2) {
//       setState(() {
//         driverSide = path;
//         driverSideTimeStamp = time;
//         driverSideLocation = location;
//       });
//     } else if (idx == 3) {
//       setState(() {
//         rearRightHandSide = path;
//         rearRightHandSideTimeStamp = time;
//         rearRightHandSideLocation = location;
//       });
//     } else if (idx == 4) {
//       setState(() {
//         rearSide = path;
//         rearSideTimeStamp = time;
//         rearSideLocatiom = location;
//       });
//     } else if (idx == 5) {
//       setState(() {
//         rearLeftHandSide = path;
//         rearLeftHandSideTimeStamp = time;
//         rearLeftHandSideLocation = location;
//       });
//     } else if (idx == 6) {
//       setState(() {
//         passengerSide = path;
//         passengerSideTimeStamp = time;
//         passengerSideLocation = location;
//       });
//     } else if (idx == 7) {
//       setState(() {
//         frontLeftHandSide = path;
//         frontLeftHandSideTimeStamp = time;
//         frontLeftHandSideLocation = location;
//       });
//     } else if (idx == 8) {
//       setState(() {
//         engineCompart = path;
//         engineCompartTimeStamp = time;
//         engineCompartLocation = location;
//       });
//     } else if (idx == 9) {
//       setState(() {
//         chassisNo = path;
//         chassisNoTimeStamp = time;
//         chassisNoLocation = location;
//       });
//     } else if (idx == 10) {
//       setState(() {
//         odometerCar = path;
//         odometerCarTimeStamp = time;
//         odometerCarLocation = location;
//       });
//     }
//     disablesubmit();
//   }
//
//
//   void updateCameraImages(imageData) {
//     setState(() {
//       frontSide = imageData[0]["imgPath"];
//       frontSideTimeStamp = imageData[0]["timestamp"];
//       frontSideLocation = imageData[0]["location"];
//
//       frontRightHandSide = imageData[1]["imgPath"];
//       frontRightHandSideTimeStamp = imageData[1]["timestamp"];
//       frontRightHandSideLocation = imageData[1]["location"];
//
//       driverSide = imageData[2]["imgPath"];
//       driverSideTimeStamp = imageData[2]["timestamp"];
//       driverSideLocation = imageData[2]["location"];
//
//       rearRightHandSide = imageData[3]["imgPath"];
//       rearRightHandSideTimeStamp = imageData[3]["timestamp"];
//       rearRightHandSideLocation = imageData[3]["location"];
//
//       rearSide = imageData[4]["imgPath"];
//       rearSideTimeStamp = imageData[4]["timestamp"];
//       rearSideLocatiom = imageData[4]["location"];
//
//       rearLeftHandSide = imageData[5]["imgPath"];
//       rearLeftHandSideTimeStamp = imageData[5]["timestamp"];
//       rearLeftHandSideLocation = imageData[5]["location"];
//
//       passengerSide = imageData[6]["imgPath"];
//       passengerSideTimeStamp = imageData[6]["timestamp"];
//       passengerSideLocation = imageData[6]["location"];
//
//       frontLeftHandSide = imageData[7]["imgPath"];
//       frontLeftHandSideTimeStamp = imageData[7]["timestamp"];
//       frontLeftHandSideLocation = imageData[7]["location"];
//
//       engineCompart = imageData[8]["imgPath"];
//       engineCompartTimeStamp = imageData[8]["timestamp"];
//       engineCompartLocation = imageData[8]["location"];
//
//       chassisNo = imageData[9]["imgPath"];
//       chassisNoTimeStamp = imageData[9]["timestamp"];
//       chassisNoLocation = imageData[9]["location"];
//
//       odometerCar = imageData[10]["imgPath"];
//       odometerCarTimeStamp = imageData[10]["timestamp"];
//       odometerCarLocation = imageData[10]["location"];
//     });
//     disablesubmit();
//   }
//
//
//   final ImagePicker _picker = ImagePicker();
//
//   dynamic showUploadOptions(Function updateData) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         alignment: Alignment.center,
//         content: Container(
//           height: ResHeight(200),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   child: const Text('Camera'),
//                   onPressed: () async {
//                     Get.back();
//                     final XFile? photo = await _picker.pickImage(
//                         source: ImageSource.camera,
//                         imageQuality: 30,
//                         maxHeight: 1280,
//                         maxWidth: 720);
//                     File image = File('photo');
//                     // Or any other way to get a File instance.
//                     //  print(getFilesizeString(bytes: photo.lengthSync());
//                     // var decodedImage =
//                     //     await decodeImageFromList(image.readAsBytesSync());
//                     // print(decodedImage.width);
//                     // print(decodedImage.height);
//                     // final size = ImageSizeGetter.getSize(FileInput(image));
//                     // print('jpg = $size');
//
//                     var location = await determinePosition();
//                     DateTime currentPhoneDate = DateTime.now();
//                     updateData(photo?.path, currentPhoneDate.toString(),
//                         "${location.latitude};${location.longitude}");
//                   },
//                   style: ButtonStyle(
//                     elevation: MaterialStateProperty.all(0),
//                     backgroundColor: MaterialStateProperty.all(yellow),
//                   ),
//                 ),
//                 SizedBox(
//                   height: ResHeight(20),
//                 ),
//                 ElevatedButton(
//                   child: const Text('Gallery'),
//                   onPressed: () async {
//                     Get.back();
//
//                     final XFile? photo = await _picker.pickImage(
//                         source: ImageSource.gallery,
//                         imageQuality: 30,
//                         maxHeight: 1280,
//                         maxWidth: 720);
//                     var location = await determinePosition();
//                     DateTime currentPhoneDate = DateTime.now();
//                     updateData(photo?.path, currentPhoneDate.toString(),
//                         "${location.latitude};${location.longitude}");
//                   },
//                   style: ButtonStyle(
//                     elevation: MaterialStateProperty.all(0),
//                     backgroundColor: MaterialStateProperty.all(yellow),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   bool uploading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             alignment: Alignment.center,
//             title: Text("Are you sure you want to go back?"),
//             content: Container(
//               height: ResHeight(80),
//               child: Center(
//                 child: Text(
//                     "Going back will revert all your progress done till now"),
//               ),
//             ),
//             actions: [
//               ElevatedButton(
//                   onPressed: () {
//                     Get.back();
//                     Get.back();
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text("Yes"),
//                   )),
//               ElevatedButton(
//                   onPressed: () {
//                     Get.back();
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text("No"),
//                   ))
//             ],
//           ),
//         );
//         return false;
//       },
//       child: SafeArea(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Scaffold(
//               appBar: AppBar(
//                 backgroundColor: white,
//                 elevation: 0,
//                 title: Text(
//                   "Upload images",
//                   style: TextStyle(
//                       color: Colors.blue[900], fontWeight: FontWeight.bold),
//                 ),
//                 iconTheme: IconThemeData(color: Colors.black),
//               ),
//               body: SingleChildScrollView(
//                 child: Container(
//                   child: Column(children: [
//                     SizedBox(
//                       height: 30,
//                     ),
//                     Center(
//                         child: Text(
//                           "Take the vehicle image using camera",
//                           style: TextStyle(fontSize: 16, color: Colors.blue[900]),
//                         )),
//                     Center(
//                       child: ElevatedButton(
//                         child: odometerCar == ""
//                             ? Text('Take Images',
//                             style: TextStyle(
//                                 fontSize: 16, color: Colors.blue[900]))
//                             : Text('Retake Images',
//                             style: TextStyle(
//                                 fontSize: 16, color: Colors.blue[900])),
//                         onPressed: () async {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) => AlertDialog(
//                               alignment: Alignment.center,
//                               title: Text("Image Upload Instructions",
//                                   style: TextStyle(
//                                       fontSize: 16, color: Colors.blue[900])),
//                               content: Container(
//                                 height: ResHeight(300),
//                                 child: const Center(
//                                   child: Text(
//                                       "The photos to be captured in proper day-light and open area only. Please do not click the photos in covered area such as garages, underground & parking areas etc."),
//                                 ),
//                               ),
//                               actions: [
//                                 ElevatedButton(
//                                     style: ButtonStyle(
//                                         elevation: MaterialStateProperty.all(0),
//                                         backgroundColor:
//                                         MaterialStateProperty.all(yellow)),
//                                     onPressed: () async {
//                                       print("doneeeeeeeee");
//                                       Get.back();
//                                       Get.to(CameraImageUpload(
//                                         updateCameraImages,
//                                         false,
//                                         "",
//                                             () {},
//                                         0,
//                                       ));
//                                     },
//                                     child: const Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Text("Continue",
//                                           style: TextStyle(
//                                               fontSize: 16,
//                                               color: Color(0xFF0D47A1))),
//                                     )),
//                               ],
//                             ),
//                           );
//                         },
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all(yellow),
//                         ),
//                       ),
//                     ),
//                     odometerCar != ""
//                         ? Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Front Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.blue[900]),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Front Side",
//                                       updateSingleImage,
//                                       0,
//                                     ));
//                                   },
//                                   child: Text("Retake",
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           color: Color(0xFF0D47A1))))
//                             ],
//                           ),
//                           Image.network(frontSide),
//
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Front RightHand Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Front RightHand Side",
//                                       updateSingleImage,
//                                       1,
//                                     ));
//                                   },
//                                   child: Text("Retake",
//                                       style: TextStyle(
//                                           color: Color(0xFF0D47A1))))
//                             ],
//                           ),
//                           Image.network(frontRightHandSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Driver Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Driver Side",
//                                       updateSingleImage,
//                                       2,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(driverSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Rear RightHand Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Rear RightHand Side",
//                                       updateSingleImage,
//                                       3,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(rearRightHandSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Rear Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Rear Side",
//                                       updateSingleImage,
//                                       4,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(rearSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Rear LeftHand Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Rear LeftHand Side",
//                                       updateSingleImage,
//                                       5,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(rearLeftHandSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Passenger Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Passenger Side",
//                                       updateSingleImage,
//                                       6,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(passengerSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Front LeftHand Side",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Front LeftHand Side",
//                                       updateSingleImage,
//                                       7,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(frontLeftHandSide),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Engine Compart",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Engine Compart",
//                                       updateSingleImage,
//                                       8,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(engineCompart),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Chassis Number",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF0D47A1)),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Chassis Number",
//                                       updateSingleImage,
//                                       9,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(chassisNo),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Odometer Car",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                               ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                     MaterialStateProperty.all(yellow),
//                                     elevation: MaterialStateProperty.all(0),
//                                   ),
//                                   onPressed: () {
//                                     Get.to(CameraImageUpload(
//                                           () {},
//                                       true,
//                                       "Odometer Car",
//                                       updateSingleImage,
//                                       10,
//                                     ));
//                                   },
//                                   child: Text(
//                                     "Retake",
//                                     style:
//                                     TextStyle(color: Color(0xFF0D47A1)),
//                                   ))
//                             ],
//                           ),
//                           Image.network(odometerCar),
//                           SizedBox(
//                             height: 24,
//                           ),
//                         ],
//                       ),
//                     )
//                         : Container(),
//                     SizedBox(
//                       height: 30,
//                     ),
//                     // Center(
//                     //   child: Text(
//                     //     "Upload/Click required Documents/Images",
//                     //     style: TextStyle(fontSize: 16,color: Color(0xFF0D47A1) ),
//                     //   ),
//                     // ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Card(
//                       elevation: 0,
//                       child: Container(
//                         width: MediaQuery.of(context).size.width,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           // child: Column(
//                           //   children: [
//                           //  Cgupload(
//                           //         'Inspection Certificate',
//                           //         inspectionCert,
//                           //         updateInspectionCert,
//                           //         showUploadOptions),
//                           //
//                           //
//                           //
//                           //     //   padding: EdgeInsets.symmetric(horizontal: 10),
//                           //     //   child: Center(
//                           //     //     child: Text(
//                           //     //       "Some IC Msg here random text random text radom text random text",
//                           //     //       style: TextStyle(fontSize: 16),
//                           //     //     ),
//                           //     //   ),
//                           //     // ),
//                           //     // SizedBox(
//                           //     //   height: 14,
//                           //     // ),
//                           //     Cgupload('Optional 1', optional1, updateOptional1,
//                           //         showUploadOptions),
//                           //     SizedBox(
//                           //       height: 14,
//                           //     ),
//                           //     Cgupload('Optional 2', optional2, updateOptional2,
//                           //         showUploadOptions),
//                           //   ],
//                           // ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 35,
//                     ),
//                     odometerCar != "" && odometerCar.isNotEmpty
//                         ? Center(
//                       child: ElevatedButton(
//                         child: Text(
//                           "Submit Form",
//                           style: TextStyle(
//                               fontSize: 16, color: Color(0xFF0D47A1)),
//                         ),
//                         onPressed: _pickAndSubmitImages,
//                         style: ButtonStyle(
//                           elevation: MaterialStateProperty.all(0),
//                           backgroundColor:
//                           MaterialStateProperty.all(yellow),
//                         ),
//                       ),
//                     )
//                         : Container()
//                   ],
//                   ),
//                 ),
//               ),
//             ),
//             uploading
//                 ? Scaffold(
//               backgroundColor: Color.fromARGB(122, 0, 0, 0),
//               body: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       color: yellow,
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     Text(
//                       "Uploading Images...",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     )
//                   ],
//                 ),
//               ),
//             )
//                 : Container()
//           ],
//         ),
//       ),
//     );
//   }
// }


