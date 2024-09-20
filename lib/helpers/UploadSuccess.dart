import 'package:cardemo/helpers/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadSuccess extends StatelessWidget {
  String pospName;
  UploadSuccess(this.pospName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done,
              color: green,
              size: 120,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Text(
                pospName == ""
                    ? "Image uploaded successfully"
                    : "Image uploaded successfully. Kindly contact POSP $pospName for further process",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('Close'),
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(red),
                  elevation: MaterialStateProperty.all(0)),
            )
          ],
        ),
      )),
    );
  }
}
