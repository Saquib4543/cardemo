import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cardemo/extractionapi.dart';
import 'package:get/get.dart';
import 'package:cardemo/displayinfo.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> with TickerProviderStateMixin {
  Uint8List? _imageData;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();  // Step 1

  void _pickImage({bool useCamera = false}) {
    final input = html.FileUploadInputElement()
      ..accept = useCamera ? 'image/*;capture=camera' : 'image/*';
    input.click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          _imageData = base64.decode(reader.result!.toString().split(",").last);
        });
      });
    });
  }



  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true); // This makes the animation go back and forth

    _colorAnimation = ColorTween(
      begin: Colors.yellow,
      end: Color(0xFF0D47A1),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Please Upload your RC', style: TextStyle(color: Colors.yellow)),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_isLoading) ...[  // if the loader flag is true, show the loader
                CircularProgressIndicator(
                  valueColor: _colorAnimation, // Use the color animation
                ),
                SizedBox(height: 20), // Spacer
                Text('Validating...'),
              ] else if (_imageData != null) ...[
                Image.memory(_imageData!),
              SizedBox(height: 20), // Spacer
              ElevatedButton(
                child: Text('Upload', style: TextStyle(color: Color(0xFF0D47A1))),
                onPressed: () async {
                  // Start the animation and show the loader
                  setState(() {
                    _isLoading = true;
                  });

                  print("Starting image upload");
                  Map responseText = await ImageUploadService().uploadImage(_imageData!);
                  print(responseText);
                  print("Finished image upload");
                  print("checkkkkkkkkkkk");
                  print(responseText);
                  print("patachele");
                  String rcRegNumber = responseText['result']['output']['rc_reg_number'];
                  print(rcRegNumber);

                  var vahaan_response = await ImageUploadService().sendRcRegNumber(rcRegNumber);
                  print(vahaan_response);
                  final data = json.decode(vahaan_response);
                  final selectedData = data['data'].entries.where((entry) {
                    return entry.key != 'client_id';  // Exclude the keys you don't want, e.g., client_id
                  }).map((entry) {
                    if (entry.value == null) {
                      return MapEntry(entry.key, 'No Data Present');
                    }
                    return entry;
                  }).toList();

                  Get.to(DetailPage(selectedEntries: selectedData));

                  // Stop the animation and hide the loader
                  setState(() {
                    _isLoading = false;
                  });
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                ),
                // ... other button properties ...
              ),
              SizedBox(height: 10), // Spacer
              ElevatedButton(
                child: Text('Retake', style: TextStyle(color: Color(0xFF0D47A1))),
                onPressed: () {
                  setState(() {
                    _imageData = null;
                  });
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                ),
              ),
            ]
            else ...[
              ElevatedButton(
                child: Text('Choose from Gallery', style: TextStyle(color: Color(0xFF0D47A1))),
                onPressed: () => _pickImage(),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                ),
              ),
              SizedBox(height: 10), // Spacer
              ElevatedButton(
                child: Text('Take a Photo', style: TextStyle(color: Color(0xFF0D47A1))),
                onPressed: () => _pickImage(useCamera: true),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                ),
              ),
            ]
            ]

        ),
      ),
    );
  }
}
// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cardemo/extractionapi.dart';
//
// class ImageUploadPage extends StatefulWidget {
//   @override
//   _ImageUploadPageState createState() => _ImageUploadPageState();
// }
//
// class _ImageUploadPageState extends State<ImageUploadPage> {
//   Uint8List? _imageData;
//
//   void _pickImage({bool useCamera = false}) async {
//     final picker = ImagePicker();
//     final pickedFile = useCamera
//         ? await picker.getImage(source: ImageSource.camera)
//         : await picker.getImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       _imageData = await pickedFile.readAsBytes();
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppB
//         title: Text('Upload License & RC', style: TextStyle(color: Color(0xFF0D47A1))),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_imageData != null) ...[
//               Image.memory(_imageData!),
//               SizedBox(height: 20), // Spacer
//               ElevatedButton(
//                 child: Text('Upload', style: TextStyle(color: Color(0xFF0D47A1))),
//                 onPressed: () async {
//                   print(_imageData);
//                   var response = await ImageUploadService().uploadImage(_imageData!);
//                   print("checkkkkkkkkkkk");
//                   print(response);
//                 },
//                 style: ButtonStyle(
//                   elevation: MaterialStateProperty.all(0),
//                   backgroundColor: MaterialStateProperty.all(Colors.yellow),
//                 ),
//               ),
//               SizedBox(height: 10), // Spacer
//               ElevatedButton(
//                 child: Text('Retake', style: TextStyle(color: Color(0xFF0D47A1))),
//                 onPressed: () {
//                   setState(() {
//                     _imageData = null;
//                   });
//                 },
//                 style: ButtonStyle(
//                   elevation: MaterialStateProperty.all(0),
//                   backgroundColor: MaterialStateProperty.all(Colors.yellow),
//                 ),
//               ),
//             ]
//             else ...[
//               ElevatedButton(
//                 child: Text('Choose from Gallery', style: TextStyle(color: Color(0xFF0D47A1))),
//                 onPressed: () => _pickImage(),
//                 style: ButtonStyle(
//                   elevation: MaterialStateProperty.all(0),
//                   backgroundColor: MaterialStateProperty.all(Colors.yellow),
//                 ),
//               ),
//               SizedBox(height: 10), // Spacer
//               ElevatedButton(
//                 child: Text('Take a Photo', style: TextStyle(color: Color(0xFF0D47A1))),
//                 onPressed: () => _pickImage(useCamera: true),
//                 style: ButtonStyle(
//                   elevation: MaterialStateProperty.all(0),
//                   backgroundColor: MaterialStateProperty.all(Colors.yellow),
//                 ),
//               ),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
