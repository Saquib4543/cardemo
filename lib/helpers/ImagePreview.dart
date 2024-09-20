import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardemo/helpers/getCurrentPosition.dart';
import 'package:cardemo/helpers/responsive.dart';

class ImagePreview extends StatefulWidget {
  final String originalPath;
  final Function incrementIndex;
  final Function updateResult;

  ImagePreview(this.originalPath, this.incrementIndex, this.updateResult, {Key? key}) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool isProcessing = false; // State to manage loader visibility

  void startProcessing(Function action) async {
    setState(() {
      isProcessing = true; // Show loader
    });

    await action();

    setState(() {
      isProcessing = false; // Hide loader after action completes
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            width: isMobile ? ResWidth(300) : ResWidth(500),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.originalPath,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes!)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResHeight(20)),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: isProcessing
                                    ? null // Disable button while processing
                                    : () {
                                  startProcessing(() async {
                                    var location = await determinePosition();
                                    DateTime currentPhoneDate = DateTime.now();
                                    widget.updateResult(widget.originalPath, currentPhoneDate.toString(),
                                        "${location.latitude};${location.longitude}");
                                    widget.incrementIndex();
                                    Get.back();
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.task_alt, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      "Confirm",
                                      style: TextStyle(fontSize: isMobile ? 14 : 18),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: ResWidth(20)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: isProcessing
                                    ? null // Disable button while processing
                                    : () {
                                  startProcessing(() {
                                    // Handle retake action here
                                    Get.back();
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.replay, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      "Retake",
                                      style: TextStyle(fontSize: isMobile ? 14 : 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (isProcessing) // Show loader while processing
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
