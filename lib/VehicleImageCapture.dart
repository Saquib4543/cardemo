import 'dart:async';
import 'dart:isolate';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import 'package:camera/camera.dart';
import 'package:cardemo/otp.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:cardemo/helpers/routeobserver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import 'main.dart';



class VehicleImageCapture extends StatefulWidget {
  final String make;
  final String model;


  VehicleImageCapture({required this.make, required this.model});

  @override
  _VehicleImageCaptureState createState() => _VehicleImageCaptureState();
}



class _VehicleImageCaptureState extends State<VehicleImageCapture> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late AnimationController _animationController;
  bool _isHorizontal = false;
  bool _cameraError = false;
  String _errorMessage = '';
  String? retakingView;
  bool _isFlashOn = false;
  bool _isSoundOn = true;
  Position? _currentPosition;
  String _locationInfo = '';

  FlashMode _flashMode = FlashMode.off;
  Map<String, Uint8List?> images = {
    "Front Side": null,
    "Front Right": null,
    "Rear Right": null,
    "Back Side": null,
    "Rear Left": null,
    "Front Left": null,
  };
  String currentView = "Front Side";
  bool allImagesCaptured = false;
  bool isCapturing = false;
  bool isSubmitting = false;
  String submitStatus = '';
  String _addressInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getCurrentLocation();

    _isSoundOn = true;

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }



  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(backCamera, ResolutionPreset.veryHigh);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }




  Future<void> _captureImage() async {
    if (!_isHorizontal || _cameraError) return;
    setState(() => isCapturing = true);
    try {
      await _initializeControllerFuture;

      if (_isSoundOn) {
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (e) {
          print('Error playing sound: $e');
        }
      }

      final image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      // Process the image to add location and timestamp
      final processedImage = await _processImage(imageBytes);

      setState(() {
        if (retakingView != null) {
          images[retakingView!] = processedImage;
          retakingView = null;
        } else {
          images[currentView] = processedImage;
          _moveToNextView();
        }
        isCapturing = false;
        allImagesCaptured = images.values.every((img) => img != null);
      });
    } catch (e) {
      print(e);
      setState(() {
        isCapturing = false;
        _errorMessage = 'Failed to capture image: ${e.toString()}';
      });
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      // Fetch the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Fetch the placemarks (address) from the coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Get the first placemark (address details)
      Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();

      // Update state with location and address information
      setState(() {
        _currentPosition = position;
        _locationInfo = '${position.latitude}, ${position.longitude}';
        _addressInfo = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
      });

      // Print address for debugging
      print('Location: $_locationInfo');
      print('Address: $_addressInfo');

    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationInfo = 'Location unavailable';
        _addressInfo = 'Address unavailable';
      });
    }
  }
  Future<Uint8List> _processImage(Uint8List imageBytes) async {
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return imageBytes;

    final captureTime = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(captureTime);
    final unixTimestamp = captureTime.millisecondsSinceEpoch.toString();

    // Function to draw text with outline
    void drawTextWithOutline(img.Image image, String text, int x, int y) {
      // Draw black outline
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          if (dx != 0 || dy != 0) {
            img.drawString(image, img.arial_24, x + dx, y + dy, text, color: img.getColor(0, 0, 0));
          }
        }
      }
      // Draw white text
      img.drawString(image, img.arial_24, x, y, text, color: img.getColor(255, 255, 255));
    }

    // Estimate text width (assuming monospace font for simplicity)
    int estimateTextWidth(String text) {
      return text.length * 14; // Estimate 14 pixels per character
    }

    // Calculate text positions on the right side
    final int rightMargin = 10;
    final int maxTextWidth = [
      estimateTextWidth('Time: $timestamp'),
      estimateTextWidth('Coords: $_locationInfo'),
      estimateTextWidth('Location: $_addressInfo'),
      estimateTextWidth('Unix: $unixTimestamp')
    ].reduce((max, width) => width > max ? width : max);

    final int xPosition = originalImage.width - maxTextWidth - rightMargin;

    // Draw timestamp
    drawTextWithOutline(originalImage, 'Time: $timestamp', xPosition, 10);

    // Draw coordinates
    drawTextWithOutline(originalImage, 'Coords: $_locationInfo', xPosition, 40);

    // Draw address
    drawTextWithOutline(originalImage, 'Location: $_addressInfo', xPosition, 70);

    // Draw Unix timestamp (milliseconds since epoch)
    drawTextWithOutline(originalImage, 'Unix: $unixTimestamp', xPosition, 100);

    return Uint8List.fromList(img.encodeJpg(originalImage));
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      _flashMode = _isFlashOn ? FlashMode.torch : FlashMode.off;
      await _controller!.setFlashMode(_flashMode);
      setState(() {});
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  // New method to toggle sound
  void _toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
    });
  }

  // New method to set focus
  Future<void> _setFocusPoint(TapDownDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    final size = MediaQuery.of(context).size;
    final offset = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    try {
      await _controller!.setFocusPoint(offset);
      await _controller!.setExposurePoint(offset);
    } catch (e) {
      print('Error setting focus: $e');
    }
  }

  void _moveToNextView() {
    final keys = images.keys.toList();
    final currentIndex = keys.indexOf(currentView);
    if (currentIndex < keys.length - 1) {
      setState(() {
        currentView = keys[currentIndex + 1];
      });
    } else {
      setState(() {
        allImagesCaptured = true;
      });
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (int i = 0; i < pickedFiles.length; i++) {
        final XFile file = pickedFiles[i];
        final Uint8List imageBytes = await file.readAsBytes();
        final String key = images.keys.elementAt(i % images.length);
        images[key] = imageBytes;
      }
      setState(() {
        allImagesCaptured = true;
      });
    } else {
      print('No images selected.');
    }
  }

  Future<void> _retakeImage(String view) async {
    setState(() {
      retakingView = view;
      allImagesCaptured = false;
    });

    await _initializeCamera();

    // Force a rebuild to show the camera preview
    setState(() {});
  }

  //  //157


  Future<void> sendFormDataToApi({
    required String make,
    required String model,
    required Map<String, Uint8List?> images,
  }) async {
    setState(() {
      isSubmitting = true;
      submitStatus = 'Preparing submission...';
    });

    final Uri url = Uri.parse('https://damage-detection.goclaims.in/fw_damage/create_fw_claim');
    var request = http.MultipartRequest('POST', url);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – HH:mm:ss').format(now);

    // Add form fields (keep your existing form fields)

    final formFields = {
      'datepicker_date': '2024-08-19',
      'location': 'Mumbai',
      'make': make,
      'select_model': model,
      'select_body_type': 'Metallic',
      'select_variant': 'Car',
      'mfg_year': '2024',
      'select_city': 'Tire 1',
      'paint_type': 'Solid',
      'reg_date': '2014-08-19',
      'vehicle_number': 'MH02DD8596',
      'compulsory_excess': 'Some valie',
      'odometer': '5000',
      'claim_number': 'IAIL API Test - $formattedDate',
      'incident_location': 'Mumbai, khar',
      'loss_type': 'Accident',
      'policy_number': '12345678',
      'full_name': 'Tauheed Ahmed Ansari',
      'permanent_address_line1': 'Sample Address 1',
      'permanent_address_line2': 'Sample Address 2',
      'city_district': 'Mumbai Suburban',
      'state': 'Maharashtra',
      'country': 'India',
      'pincode': '400055',
      'mobile': '9321024084',
      'email': 'tauheed.ansari@iail.in',
      'date_of_registration': '01-01-2024',
      'registration_number': '87459621',
      'engine_number': '254178',
      'chassis_number': '5955412',
      'driver_full_name': 'Aftab Ansari',
      'gender': 'Male',
      'date_of_birth': '09-10-2000',
      'driving_license_number': '88596574',
      'license_issuing_authority': 'Test',
      'license_expiry_date': '05-05-2032',
      'license_for_vehicle_type': 'LMV',
      'temporary_license': 'false',
      'relation_with_insured': 'Me',
      'employment_duration': '1',
      'under_influence': 'false',
      'endorsements_or_suspensions': 'No',
      'date_of_accident': '01-07-2024',
      'time_of_accident': '02:00PM',
      'speed_of_vehicle': '90',
      'number_of_occupants': '1',
      'location_of_accident': 'Snatacruz',
      'description_of_accident': 'none',
      'reported_to_police': 'false',
      'not_reported_reason': 'Taken care',
      'police_station_name': 'None',
      'fir_number': 'None',
      'garage_name': 'Viakas garage',
      'garage_contact_person': 'Ramesh',
      'garage_address': 'None',
      'garage_phone_number': '9632587410',
      'fitness_valid_upto': '1 Year',
      'load_carried_at_accident_time': 'None',
      'permit_valid_upto': '5 year',
      'injury_name': 'Same',
      'injury_phone_number': '9632587410',
      'nature_of_injury': 'None',
      'injury_capacity': 'None',
      'injury_address': 'None',
      'description_of_damage': 'None',
      'date_of_theft': 'None',
      'time_of_theft': 'None',
      'place_of_theft': 'None',
      'circumstances_of_theft': 'None',
      'items_stolen': 'None',
      'estimated_cost_of_replacement': '15000',
      'thef_discoverd_reported_by': 'None',
      'theft_reported_to_police': 'true',
      'theft_police_station_name': 'None',
      'theft_fir_number': 'None',
      'thef_fir_date': 'None',
      'thef_fir_time': 'None',
      'thef_attending_inspector': 'None',
      'bank_name': 'ICICI',
      'account_number': 'Tauheed Ansari',
      'ifsc_micr_code': 'MICR001',
      'account_holder_name': 'Tauheed Andari',
      'vehicle_repair_satisfaction': '100%',
      'claim_discharge_voucher': 'None',
      'signature_thumb_impression': 'True',
      'declaration_date': '29-08-2024',
      'declaration_place': 'Mumbai,Santacruz',
    };


    formFields.forEach((key, value) {
      request.fields[key] = value;
    });

    final uuid = Uuid();
    int totalImages = images.length;
    int uploadedImages = 0;

    for (final entry in images.entries) {
      final key = entry.key;
      final value = entry.value;
      String uniqueFileName = '${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (value != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[]',
            value,
            filename: uniqueFileName,
          ),
        );
        uploadedImages++;
        setState(() {
          submitStatus = 'Preparing images... ${(uploadedImages / totalImages * 100).toInt()}%';
        });
      }
    }

    print('Prepared $uploadedImages out of $totalImages images');

    setState(() {
      submitStatus = 'Sending data to server...';
    });

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(responseBody);
        print('API call successful: $jsonResponse');
        setState(() {
          submitStatus = 'Submission successful!';
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
              (Route<dynamic> route) => false,
        );
      } else {
        final errorResponse = json.decode(responseBody);
        throw Exception('Failed to upload data: ${response.statusCode} - ${errorResponse['message']}');
      }
    } catch (e) {
      print('Error sending form data: $e');
      setState(() {
        submitStatus = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }




  Widget _buildImagePreview() {
    return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final key = images.keys.elementAt(index);
              final imageBytes = images[key];
              return Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: imageBytes != null
                          ? Image.memory(imageBytes, fit: BoxFit.cover)
                          : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () => _retakeImage(key),
                            child: Text('Retake'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size(double.infinity, 30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  Widget _buildCameraErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Camera not available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _pickImagesFromGallery,
            child: Text('Select Images from Gallery'),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 0.2,
          child: Icon(
            Icons.screen_rotation,
            size: 100,
            color: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_locationInfo);
    print(_addressInfo);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String?>;
    final make = args['make'];
    final model = args['model'];
    final accidentType = args['accidentType'];
    print('ACCIDENT $accidentType');

    return Scaffold(
      body: Stack(
        children: [
          if (allImagesCaptured)
            Column(
              children: [
                Expanded(child: _buildImagePreview()),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (submitStatus.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              submitStatus,
                              style: TextStyle(
                                color: submitStatus.startsWith('Error')
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                            sendFormDataToApi(
                              make: make ?? '',
                              model: model ?? '',
                              images: images,
                            );
                          },
                          child: isSubmitting
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Submit Images'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: TextStyle(fontSize: 18),
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else if (_cameraError)
            _buildCameraErrorUI()
          else
            OrientationBuilder(
              builder: (context, orientation) {
                _isHorizontal = orientation == Orientation.landscape;
                return FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.black),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: GestureDetector(
                                onTapDown: _setFocusPoint,
                                child: AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: CameraPreview(_controller!),
                                ),
                              ),
                            ),
                          ),
                          if (!_isHorizontal)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildRotationAnimation(),
                                    SizedBox(height: 20),
                                    Text(
                                      'Please rotate your device',
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_isHorizontal)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: isCapturing ? null : _captureImage,
                                      child: Icon(Icons.camera),
                                      backgroundColor: isCapturing ? Colors.grey : null,
                                    ),
                                    SizedBox(height: 20),
                                    FloatingActionButton(
                                      onPressed: _toggleFlash,
                                      child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                                    ),
                                    SizedBox(height: 20),
                                    FloatingActionButton(
                                      onPressed: _toggleSound,
                                      child: Icon(_isSoundOn ? Icons.volume_up : Icons.volume_off),
                                    ),
                                    SizedBox(height: 20),
                                    FloatingActionButton(
                                      onPressed: _pickImagesFromGallery,
                                      child: Icon(Icons.photo_library),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SafeArea(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  retakingView != null ? 'Retake $retakingView' : 'Capture $currentView',
                                  style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
            ),
          if (isSubmitting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: submitStatus.contains('%')
                          ? double.parse(submitStatus.split('%')[0].split('... ')[1]) / 100
                          : null,
                    ),
                    SizedBox(height: 20),
                    Text(
                      submitStatus,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}




















// import 'package:camera/camera.dart';
// import 'package:cardemo/otp.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:get/get.dart';
// import 'package:cardemo/helpers/routeobserver.dart';
// import 'package:intl/intl.dart';
//
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:http/http.dart' as http;
// import 'package:flutter/services.dart';
// import 'dart:html' as html;
// import 'dart:typed_data';
//
// import 'main.dart';
//
//
//
// class VehicleImageCapture extends StatefulWidget {
//   final String make;
//   final String model;
//
//   VehicleImageCapture({required this.make, required this.model});
//
//   @override
//   _VehicleImageCaptureState createState() => _VehicleImageCaptureState();
// }
//
//
//
// class _VehicleImageCaptureState extends State<VehicleImageCapture> with SingleTickerProviderStateMixin {
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   late AnimationController _animationController;
//   bool _isHorizontal = false;
//   Map<String, Uint8List?> images = {
//     "Front Side": null,
//     "Back Side": null,
//     "Front Right": null,
//     "Front Left": null,
//     "Rear Right": null,
//     "Rear Left": null,
//   };
//   String currentView = "Front Side";
//   bool allImagesCaptured = false;
//   bool isCapturing = false;
//   bool isSubmitting = false;
//   String submitStatus = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..repeat(reverse: true);
//   }
//
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final backCamera = cameras.firstWhere(
//           (camera) => camera.lensDirection == CameraLensDirection.back,
//       orElse: () => cameras.first,
//     );
//     _controller = CameraController(backCamera, ResolutionPreset.veryHigh);
//     _initializeControllerFuture = _controller!.initialize();
//     setState(() {});
//   }
//
//   Future<void> _captureImage() async {
//     if (!_isHorizontal) return; // Prevent capture if not horizontal
//     setState(() => isCapturing = true);
//     try {
//       await _initializeControllerFuture;
//       final image = await _controller!.takePicture();
//       final imageBytes = await image.readAsBytes();
//       setState(() {
//         images[currentView] = imageBytes;
//         isCapturing = false;
//       });
//       if (!allImagesCaptured) {
//         _moveToNextView();
//       } else {
//         setState(() {});
//       }
//     } catch (e) {
//       print(e);
//       setState(() => isCapturing = false);
//     }
//   }
//
//   void _moveToNextView() {
//     final keys = images.keys.toList();
//     final currentIndex = keys.indexOf(currentView);
//     if (currentIndex < keys.length - 1) {
//       setState(() {
//         currentView = keys[currentIndex + 1];
//       });
//     } else {
//       setState(() {
//         allImagesCaptured = true;
//       });
//     }
//   }
//
//   Future<void> sendFormDataToApi({
//     required String make,
//     required String model,
//     required Map<String, Uint8List?> images,
//   }) async {
//     final stopwatch = Stopwatch()..start();
//
//     setState(() {
//       isSubmitting = true;
//       submitStatus = 'Submitting...';
//     });
//
//     final Uri url = Uri.parse('https://damage-detection.goclaims.in/fw_damage/create_fw_claim');
//     var request = http.MultipartRequest('POST', url);
//     DateTime now = DateTime.now();
//
//     // Format the timestamp
//     String formattedDate = DateFormat('yyyy-MM-dd – HH:mm:ss').format(now);
//
//     // Add form fields
//     final formFields = {
//       'datepicker_date': '2024-08-19',
//       'location': 'Mumbai',
//       'make': make,
//       'select_model': model,
//       'select_body_type': 'Metallic',
//       'select_variant': 'Car',
//       'mfg_year': '2024',
//       'select_city': 'Tire 1',
//       'paint_type': 'Solid',
//       'reg_date': '2014-08-19',
//       'vehicle_number': 'MH02DD8596',
//       'compulsory_excess': 'Some valie',
//       'odometer': '5000',
//       'claim_number': 'IAIL API Test - $formattedDate',
//       'incident_location': 'Mumbai, khar',
//       'loss_type': 'Accident',
//       'policy_number': '12345678',
//       'full_name': 'Tauheed Ahmed Ansari',
//       'permanent_address_line1': 'Sample Address 1',
//       'permanent_address_line2': 'Sample Address 2',
//       'city_district': 'Mumbai Suburban',
//       'state': 'Maharashtra',
//       'country': 'India',
//       'pincode': '400055',
//       'mobile': '9321024084',
//       'email': 'tauheed.ansari@iail.in',
//       'date_of_registration': '01-01-2024',
//       'registration_number': '87459621',
//       'engine_number': '254178',
//       'chassis_number': '5955412',
//       'driver_full_name': 'Aftab Ansari',
//       'gender': 'Male',
//       'date_of_birth': '09-10-2000',
//       'driving_license_number': '88596574',
//       'license_issuing_authority': 'Test',
//       'license_expiry_date': '05-05-2032',
//       'license_for_vehicle_type': 'LMV',
//       'temporary_license': 'false',
//       'relation_with_insured': 'Me',
//       'employment_duration': '1',
//       'under_influence': 'false',
//       'endorsements_or_suspensions': 'No',
//       'date_of_accident': '01-07-2024',
//       'time_of_accident': '02:00PM',
//       'speed_of_vehicle': '90',
//       'number_of_occupants': '1',
//       'location_of_accident': 'Snatacruz',
//       'description_of_accident': 'none',
//       'reported_to_police': 'false',
//       'not_reported_reason': 'Taken care',
//       'police_station_name': 'None',
//       'fir_number': 'None',
//       'garage_name': 'Viakas garage',
//       'garage_contact_person': 'Ramesh',
//       'garage_address': 'None',
//       'garage_phone_number': '9632587410',
//       'fitness_valid_upto': '1 Year',
//       'load_carried_at_accident_time': 'None',
//       'permit_valid_upto': '5 year',
//       'injury_name': 'Same',
//       'injury_phone_number': '9632587410',
//       'nature_of_injury': 'None',
//       'injury_capacity': 'None',
//       'injury_address': 'None',
//       'description_of_damage': 'None',
//       'date_of_theft': 'None',
//       'time_of_theft': 'None',
//       'place_of_theft': 'None',
//       'circumstances_of_theft': 'None',
//       'items_stolen': 'None',
//       'estimated_cost_of_replacement': '15000',
//       'thef_discoverd_reported_by': 'None',
//       'theft_reported_to_police': 'true',
//       'theft_police_station_name': 'None',
//       'theft_fir_number': 'None',
//       'thef_fir_date': 'None',
//       'thef_fir_time': 'None',
//       'thef_attending_inspector': 'None',
//       'bank_name': 'ICICI',
//       'account_number': 'Tauheed Ansari',
//       'ifsc_micr_code': 'MICR001',
//       'account_holder_name': 'Tauheed Andari',
//       'vehicle_repair_satisfaction': '100%',
//       'claim_discharge_voucher': 'None',
//       'signature_thumb_impression': 'True',
//       'declaration_date': '29-08-2024',
//       'declaration_place': 'Mumbai,Santacruz',
//     };
//
//
//     formFields.forEach((key, value) {
//       request.fields[key] = value;
//     });
//
//     // Add image files
//     for (final entry in images.entries) {
//       final key = entry.key;
//       final value = entry.value;
//
//       if (value != null) {
//         final startTime = DateTime.now();
//         final compressedImage = await _compressImage(value);
//         final compressionTime = DateTime.now().difference(startTime);
//         print('Image compression took: ${compressionTime.inMilliseconds} ms');
//
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'images[]',
//             compressedImage,
//             filename: '${key.replaceAll(' ', '_')}.jpg',
//           ),
//         );
//       }
//     }
//
//     final requestTime = stopwatch.elapsedMilliseconds;
//     print('Request preparation took: $requestTime ms');
//
//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       final responseTime = stopwatch.elapsedMilliseconds - requestTime;
//       print('API response received in: $responseTime ms');
//
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final jsonResponse = json.decode(responseBody);
//         print('API call successful: $jsonResponse');
//         setState(() {
//           submitStatus = 'Submission successful!';
//         });
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => SuccessPage()),
//               (Route<dynamic> route) => false,
//         );
//       } else {
//         final errorResponse = json.decode(responseBody);
//         throw Exception('Failed to upload data: ${response.statusCode} - ${errorResponse['message']}');
//       }
//     } catch (e) {
//       print('Error sending form data: $e');
//       setState(() {
//         submitStatus = 'Error: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         isSubmitting = false;
//       });
//       stopwatch.stop();
//       print('Total time: ${stopwatch.elapsedMilliseconds} ms');
//     }
//   }
//
//   Future<Uint8List> _compressImage(Uint8List imageBytes) async {
//     final image = img.decodeImage(imageBytes);
//     if (image == null) {
//       throw Exception('Failed to decode image');
//     }
//
//     final resizedImage = img.copyResize(image, width: 800);
//     final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);
//     return Uint8List.fromList(compressedImageBytes);
//   }
//
//   void _retakeImage(String view) {
//     setState(() {
//       currentView = view;
//       allImagesCaptured = false;
//       images[view] = null;
//     });
//   }
//
//   Widget _buildImagePreview() {
//     return LayoutBuilder(
//         builder: (context, constraints) {
//           final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
//           return GridView.builder(
//             padding: EdgeInsets.all(8),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: images.length,
//             itemBuilder: (context, index) {
//               final key = images.keys.elementAt(index);
//               final imageBytes = images[key];
//               return Card(
//                 elevation: 4,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Expanded(
//                       child: imageBytes != null
//                           ? Image.memory(imageBytes, fit: BoxFit.cover)
//                           : Container(
//                         color: Colors.grey[200],
//                         child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                           SizedBox(height: 4),
//                           ElevatedButton(
//                             onPressed: () => _retakeImage(key),
//                             child: Text('Retake'),
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               minimumSize: Size(double.infinity, 30),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         }
//     );
//   }
//
//   Widget _buildRotationAnimation() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.rotate(
//           angle: _animationController.value * 0.2,
//           child: Icon(
//             Icons.screen_rotation,
//             size: 100,
//             color: Colors.white,
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)!.settings.arguments as Map<String, String?>;
//     final make = args['make'];
//     final model = args['model'];
//
//     return Scaffold(
//       body: allImagesCaptured
//           ? Column(
//         children: [
//           Expanded(child: _buildImagePreview()),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   if (submitStatus.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Text(
//                         submitStatus,
//                         style: TextStyle(
//                           color: submitStatus.startsWith('Error')
//                               ? Colors.red
//                               : Colors.green,
//                         ),
//                       ),
//                     ),
//                   ElevatedButton(
//                     onPressed: isSubmitting
//                         ? null
//                         : () {
//                       sendFormDataToApi(
//                         make: make ?? '',
//                         model: model ?? '',
//                         images: images,
//                       );
//                     },
//                     child: isSubmitting
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text('Submit Images'),
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                       textStyle: TextStyle(fontSize: 18),
//                       minimumSize: Size(double.infinity, 50),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       )
//           : OrientationBuilder(
//         builder: (context, orientation) {
//           _isHorizontal = orientation == Orientation.landscape;
//           return FutureBuilder<void>(
//             future: _initializeControllerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     Container(color: Colors.black), // Black background
//                     Center(
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.7,
//                         child: AspectRatio(
//                           aspectRatio: _controller!.value.aspectRatio,
//                           child: CameraPreview(_controller!),
//                         ),
//                       ),
//                     ),
//                     if (!_isHorizontal)
//                       Container(
//                         color: Colors.black54,
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               _buildRotationAnimation(),
//                               SizedBox(height: 20),
//                               Text(
//                                 'Please rotate your device',
//                                 style: TextStyle(color: Colors.white, fontSize: 18),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     if (_isHorizontal)
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 20.0),
//                           child: FloatingActionButton(
//                             onPressed: isCapturing ? null : _captureImage,
//                             child: Icon(Icons.camera),
//                             backgroundColor: isCapturing ? Colors.grey : null,
//                           ),
//                         ),
//                       ),
//                     SafeArea(
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Text(
//                             'Capture $currentView',
//                             style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//   @override
//   void dispose() {
//     _controller?.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
// }
//
// //
// // import 'package:flutter/material.dart';
// // import 'package:camera/camera.dart';
// // import 'package:intl/intl.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'dart:typed_data';
// // import 'package:image/image.dart' as img;
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// //
// // class VehicleImageCapture extends StatefulWidget {
// //   final String make;
// //   final String model;
// //
// //   const VehicleImageCapture({Key? key, required this.make, required this.model}) : super(key: key);
// //
// //   @override
// //   _VehicleImageCaptureState createState() => _VehicleImageCaptureState();
// // }
// //
// // class _VehicleImageCaptureState extends State<VehicleImageCapture> {
// //   CameraController? _controller;
// //   Future<void>? _initializeControllerFuture;
// //   Map<String, Uint8List?> images = {
// //     "Front Side": null,
// //     "Back Side": null,
// //     "Front Right": null,
// //     "Front Left": null,
// //     "Rear Right": null,
// //     "Rear Left": null,
// //   };
// //   String currentView = "Front Side";
// //   bool allImagesCaptured = false;
// //   bool isCapturing = false;
// //   bool isSubmitting = false;
// //   String submitStatus = '';
// //   String currentLocation = '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeCamera();
// //     _getCurrentLocation();
// //   }
// //
// //   Future<void> _initializeCamera() async {
// //     final cameras = await availableCameras();
// //     final backCamera = cameras.firstWhere(
// //           (camera) => camera.lensDirection == CameraLensDirection.back,
// //       orElse: () => cameras.first,
// //     );
// //     _controller = CameraController(backCamera, ResolutionPreset.high);
// //     _initializeControllerFuture = _controller!.initialize();
// //     setState(() {});
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //         if (permission == LocationPermission.denied) {
// //           throw Exception('Location permissions are denied');
// //         }
// //       }
// //
// //       if (permission == LocationPermission.deniedForever) {
// //         throw Exception('Location permissions are permanently denied');
// //       }
// //
// //       Position position = await Geolocator.getCurrentPosition(
// //           desiredAccuracy: LocationAccuracy.high);
// //       List<Placemark> placemarks = await placemarkFromCoordinates(
// //           position.latitude, position.longitude);
// //
// //       if (placemarks.isNotEmpty) {
// //         Placemark place = placemarks[0];
// //         setState(() {
// //           currentLocation = "${place.locality ?? ''}, ${place.country ?? ''}";
// //         });
// //       } else {
// //         setState(() {
// //           currentLocation = "Location details not available";
// //         });
// //       }
// //     } catch (e) {
// //       print("Error getting location: $e");
// //       setState(() {
// //         currentLocation = "Location unavailable";
// //       });
// //     }
// //   }  Future<void> _captureImage() async {
// //     setState(() => isCapturing = true);
// //     try {
// //       await _initializeControllerFuture;
// //       final image = await _controller!.takePicture();
// //       final imageBytes = await image.readAsBytes();
// //       final processedImage = await _processImage(imageBytes);
// //       setState(() {
// //         images[currentView] = processedImage;
// //         isCapturing = false;
// //       });
// //       if (!allImagesCaptured) {
// //         _moveToNextView();
// //       } else {
// //         setState(() {});
// //       }
// //     } catch (e) {
// //       print(e);
// //       setState(() => isCapturing = false);
// //     }
// //   }
// //
// //   Future<Uint8List> _processImage(Uint8List imageBytes) async {
// //     final image = img.decodeImage(imageBytes);
// //     if (image == null) {
// //       throw Exception('Failed to decode image');
// //     }
// //
// //     final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
// //     final location = currentLocation;
// //
// //     // Add timestamp and location to the image
// //     img.drawString(image, img.arial_24, image.width - 250, image.height - 60, timestamp,
// //         color: img.getColor(255, 255, 255),font: img.arial14);
// //     img.drawString(image, img.arial_24, image.width - 250, image.height - 30, location,
// //         color: img.getColor(255, 255, 255),font: img.arial14);
// //
// //     final processedImageBytes = img.encodeJpg(image, quality: 85);
// //     return Uint8List.fromList(processedImageBytes);
// //   }
// //
// //   void _moveToNextView() {
// //     final keys = images.keys.toList();
// //     final currentIndex = keys.indexOf(currentView);
// //     if (currentIndex < keys.length - 1) {
// //       setState(() {
// //         currentView = keys[currentIndex + 1];
// //       });
// //     } else {
// //       setState(() {
// //         allImagesCaptured = true;
// //       });
// //     }
// //   }
// //
// //   Future<void> sendFormDataToApi({
// //     required String make,
// //     required String model,
// //     required Map<String, Uint8List?> images,
// //   }) async {
// //     final stopwatch = Stopwatch()..start();
// //
// //     setState(() {
// //       isSubmitting = true;
// //       submitStatus = 'Submitting...';
// //     });
// //
// //     final Uri url = Uri.parse('https://damage-detection.goclaims.in/fw_damage/create_fw_claim');
// //     var request = http.MultipartRequest('POST', url);
// //
// //     // Add form fields
// //     final formFields = {
// //       'datepicker_date': '2024-08-19',
// //       'location': 'Mumbai',
// //       'make': make,
// //       'select_model': model,
// //       'select_body_type': 'Metallic',
// //       'select_variant': 'Car',
// //       'mfg_year': '2024',
// //       'select_city': 'Tire 1',
// //       'paint_type': 'Solid',
// //       'reg_date': '2014-08-19',
// //       'vehicle_number': 'MH02DD8596',
// //       'compulsory_excess': 'Some value',
// //       'odometer': '5000',
// //       'claim_number': 'IAIL API Test - 5',
// //       'incident_location': 'Mumbai, khar',
// //       'loss_type': 'Accident',
// //       'policy_number': '12345678',
// //       'full_name': 'Tauheed Ahmed Ansari',
// //       'permanent_address_line1': 'Sample Address 1',
// //       'permanent_address_line2': 'Sample Address 2',
// //       'city_district': 'Mumbai Suburban',
// //       'state': 'Maharashtra',
// //       'country': 'India',
// //       'pincode': '400055',
// //       'mobile': '9321024084',
// //       'email': 'tauheed.ansari@iail.in',
// //       'date_of_registration': '01-01-2024',
// //       'registration_number': '87459621',
// //       'engine_number': '254178',
// //       'chassis_number': '5955412',
// //       'driver_full_name': 'Aftab Ansari',
// //       'gender': 'Male',
// //       'date_of_birth': '09-10-2000',
// //       'driving_license_number': '88596574',
// //       'license_issuing_authority': 'Test',
// //       'license_expiry_date': '05-05-2032',
// //       'license_for_vehicle_type': 'LMV',
// //       'temporary_license': 'false',
// //       'relation_with_insured': 'Me',
// //       'employment_duration': '1',
// //       'under_influence': 'false',
// //       'endorsements_or_suspensions': 'No',
// //       'date_of_accident': '01-07-2024',
// //       'time_of_accident': '02:00PM',
// //       'speed_of_vehicle': '90',
// //       'number_of_occupants': '1',
// //       'location_of_accident': 'Santacruz',
// //       'description_of_accident': 'none',
// //       'reported_to_police': 'false',
// //       'not_reported_reason': 'Taken care',
// //       'police_station_name': 'None',
// //       'fir_number': 'None',
// //       'garage_name': 'Vikas garage',
// //       'garage_contact_person': 'Ramesh',
// //       'garage_address': 'None',
// //       'garage_phone_number': '9632587410',
// //       'fitness_valid_upto': '1 Year',
// //       'load_carried_at_accident_time': 'None',
// //       'permit_valid_upto': '5 year',
// //       'injury_name': 'Same',
// //       'injury_phone_number': '9632587410',
// //       'nature_of_injury': 'None',
// //       'injury_capacity': 'None',
// //       'injury_address': 'None',
// //       'description_of_damage': 'None',
// //       'date_of_theft': 'None',
// //       'time_of_theft': 'None',
// //       'place_of_theft': 'None',
// //       'circumstances_of_theft': 'None',
// //       'items_stolen': 'None',
// //       'estimated_cost_of_replacement': '15000',
// //       'thef_discoverd_reported_by': 'None',
// //       'theft_reported_to_police': 'true',
// //       'theft_police_station_name': 'None',
// //       'theft_fir_number': 'None',
// //       'thef_fir_date': 'None',
// //       'thef_fir_time': 'None',
// //       'thef_attending_inspector': 'None',
// //       'bank_name': 'ICICI',
// //       'account_number': 'Tauheed Ansari',
// //       'ifsc_micr_code': 'MICR001',
// //       'account_holder_name': 'Tauheed Ansari',
// //       'vehicle_repair_satisfaction': '100%',
// //       'claim_discharge_voucher': 'None',
// //       'signature_thumb_impression': 'True',
// //       'declaration_date': '29-08-2024',
// //       'declaration_place': 'Mumbai,Santacruz',
// //     };
// //
// //     formFields.forEach((key, value) {
// //       request.fields[key] = value;
// //     });
// //
// //     // Add image files
// //     for (final entry in images.entries) {
// //       final key = entry.key;
// //       final value = entry.value;
// //
// //       if (value != null) {
// //         final startTime = DateTime.now();
// //         final compressedImage = await _compressImage(value);
// //         final compressionTime = DateTime.now().difference(startTime);
// //         print('Image compression took: ${compressionTime.inMilliseconds} ms');
// //
// //         request.files.add(
// //           http.MultipartFile.fromBytes(
// //             'images[]',
// //             compressedImage,
// //             filename: '${key.replaceAll(' ', '_')}.jpg',
// //           ),
// //         );
// //       }
// //     }
// //
// //     final requestTime = stopwatch.elapsedMilliseconds;
// //     print('Request preparation took: $requestTime ms');
// //
// //     try {
// //       final response = await request.send();
// //       final responseBody = await response.stream.bytesToString();
// //
// //       final responseTime = stopwatch.elapsedMilliseconds - requestTime;
// //       print('API response received in: $responseTime ms');
// //
// //       if (response.statusCode >= 200 && response.statusCode < 300) {
// //         final jsonResponse = json.decode(responseBody);
// //         print('API call successful: $jsonResponse');
// //         setState(() {
// //           submitStatus = 'Submission successful!';
// //         });
// //         Navigator.pushAndRemoveUntil(
// //           context,
// //           MaterialPageRoute(builder: (context) => SuccessPage()),
// //               (Route<dynamic> route) => false,
// //         );
// //       } else {
// //         final errorResponse = json.decode(responseBody);
// //         throw Exception('Failed to upload data: ${response.statusCode} - ${errorResponse['message']}');
// //       }
// //     } catch (e) {
// //       print('Error sending form data: $e');
// //       setState(() {
// //         submitStatus = 'Error: ${e.toString()}';
// //       });
// //     } finally {
// //       setState(() {
// //         isSubmitting = false;
// //       });
// //       stopwatch.stop();
// //       print('Total time: ${stopwatch.elapsedMilliseconds} ms');
// //     }
// //   }
// //
// //   Future<Uint8List> _compressImage(Uint8List imageBytes) async {
// //     final image = img.decodeImage(imageBytes);
// //     if (image == null) {
// //       throw Exception('Failed to decode image');
// //     }
// //
// //     final resizedImage = img.copyResize(image, width: 800);
// //     final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);
// //     return Uint8List.fromList(compressedImageBytes);
// //   }
// //
// //   void _retakeImage(String view) {
// //     setState(() {
// //       currentView = view;
// //       allImagesCaptured = false;
// //       images[view] = null;
// //     });
// //   }
// //
// //   Widget _buildImagePreview() {
// //     return LayoutBuilder(
// //         builder: (context, constraints) {
// //           final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
// //           return GridView.builder(
// //             padding: EdgeInsets.all(8),
// //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //               crossAxisCount: crossAxisCount,
// //               crossAxisSpacing: 8.0,
// //               mainAxisSpacing: 8.0,
// //               childAspectRatio: 0.75,
// //             ),
// //             itemCount: images.length,
// //             itemBuilder: (context, index) {
// //               final key = images.keys.elementAt(index);
// //               final imageBytes = images[key];
// //               return Card(
// //                 elevation: 4,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     Expanded(
// //                       child: imageBytes != null
// //                           ? Image.memory(imageBytes, fit: BoxFit.cover)
// //                           : Container(
// //                         color: Colors.grey[200],
// //                         child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
// //                       ),
// //                     ),
// //                     Padding(
// //                       padding: const EdgeInsets.all(8.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
// //                           SizedBox(height: 4),
// //                           ElevatedButton(
// //                             onPressed: () => _retakeImage(key),
// //                             child: Text('Retake'),
// //                             style: ElevatedButton.styleFrom(
// //                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                               minimumSize: Size(double.infinity, 30),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           );
// //         }
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Vehicle Image Capture'),
// //       ),
// //       body: allImagesCaptured
// //           ? Column(
// //         children: [
// //           Expanded(child: _buildImagePreview()),
// //           SafeArea(
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Column(
// //                 children: [
// //                   if (submitStatus.isNotEmpty)
// //                     Padding(
// //                       padding: const EdgeInsets.only(bottom: 8.0),
// //                       child: Text(
// //                         submitStatus,
// //                         style: TextStyle(
// //                           color: submitStatus.startsWith('Error')
// //                               ? Colors.red
// //                               : Colors.green,
// //                         ),
// //                       ),
// //                     ),
// //                   ElevatedButton(
// //                     onPressed: isSubmitting
// //                         ? null
// //                         : () {
// //                       sendFormDataToApi(
// //                         make: widget.make,
// //                         model: widget.model,
// //                         images: images,
// //                       );
// //                     },
// //                     child: isSubmitting
// //                         ? CircularProgressIndicator(color: Colors.white)
// //                         : Text('Submit Images'),
// //                     style: ElevatedButton.styleFrom(
// //                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
// //                       textStyle: TextStyle(fontSize: 18),
// //                       minimumSize: Size(double.infinity, 50),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       )
// //           : FutureBuilder<void>(
// //         future: _initializeControllerFuture,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.done) {
// //             return Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 CameraPreview(_controller!),
// //                 if (isCapturing)
// //                   Container(
// //                     color: Colors.black54,
// //                     child: Center(child: CircularProgressIndicator()),
// //                   ),
// //                 SafeArea(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.all(16.0),
// //                         child: Text(
// //                           'Capture $currentView',
// //                           style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                       Padding(
// //                         padding: const EdgeInsets.all(16.0),
// //                         child: ElevatedButton.icon(
// //                           onPressed: isCapturing ? null : _captureImage,
// //                           icon: Icon(Icons.camera),
// //                           label: Text('Capture Image'),
// //                           style: ElevatedButton.styleFrom(
// //                             padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
// //                             textStyle: TextStyle(fontSize: 18),
// //                             backgroundColor: Colors.white,
// //                             foregroundColor: Colors.blue[700],
// //                             minimumSize: Size(double.infinity, 50),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             );
// //           } else {
// //             return Center(child: CircularProgressIndicator());
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller?.dispose();
// //     super.dispose();
// //   }
// // }
// //
// // class SuccessPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Submission Successful'),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.check_circle, color: Colors.green, size: 100),
// //             SizedBox(height: 20),
// //             Text(
// //               'Images submitted successfully!',
// //               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 Navigator.of(context).popUntil((route) => route.isFirst);
// //               },
// //               child: Text('Return to Home'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }