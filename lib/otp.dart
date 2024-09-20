import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardemo/liscencercupload.dart';


class otpenter extends StatefulWidget {
  const otpenter({Key? key}) : super(key: key);

  @override
  State<otpenter> createState() => _otpenterState();
}

class _otpenterState extends State<otpenter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <-- Set Scaffold's background color to yellow
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(Icons.arrow_back, color: Colors.blue[900])), // <-- Icon color to dark blue
                ),
                Column(
                  children: <Widget>[
                    Container(
                      // TODO: Add content if needed.
                    ),
                    Text(
                      "OTP VERIFICATION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.blue[900], // <-- Text color to dark blue
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Please Enter the OTP sent on your MobileNumber",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[900], // <-- Text color to dark blue
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
                Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _textFieldOTP(first: true, last: false), // <-- Make sure _textFieldOTP has the appropriate styling
                      _textFieldOTP(first: false, last: false),
                      _textFieldOTP(first: false, last: false),
                      _textFieldOTP(first: false, last: true),
                    ],
                  ),
                  SizedBox(
                    height: 22,
                  ),
                ]),
                FloatingActionButton.extended(
                  label: Text('Enter', style: TextStyle(color: Colors.blue[900])),
                  backgroundColor: Colors.yellow,
                  onPressed: () {
                    Get.to(ImageUploadPage());
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue[900]!, width: 2.0), // Dark blue border
                    borderRadius: BorderRadius.circular(30.0), // Rounded border
                  ),
                ),

                SizedBox(height: 16),
                Text(
                  "Did Not Receive OTP?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900], // <-- Text color to dark blue
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Resend OTP",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900], // <-- Text color to dark blue
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  _textFieldOTP({required bool first, last}) {
    return Container(
      height: 85,
      child: AspectRatio(
        aspectRatio: 0.7,
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.blue),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
