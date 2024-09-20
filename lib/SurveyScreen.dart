import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:cardemo/DynamicDropdown.dart';

class SurveyScreen extends StatefulWidget {
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _showInput = false;
  bool _isLoading = false;

  void _proceedAsSurveyor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicDropdown(),
      ),
    );
  }

  void _sendLinkToUser() {
    setState(() {
      _showInput = true;
    });
  }

  void _submitUserInput() async {
    setState(() {
      _isLoading = true;
    });

    String userInput = _controller.text.trim();
    bool isEmail = userInput.contains('@');

    try {
      QuerySnapshot policySnapshot = await FirebaseFirestore.instance
          .collection('policies')
          .where(isEmail ? 'CUST_EMAIL' : 'CUST_MOBILE', isEqualTo: userInput)
          .get();

      if (policySnapshot.docs.isNotEmpty) {
        var policyData = policySnapshot.docs.first.data() as Map<String, dynamic>;
        String uniqueUrl = 'https://yourapp.com/survey/${policyData['BREAKIN_ID']}';

        if (isEmail) {
          await _sendEmail(userInput, uniqueUrl);
        } else {
          await _sendWhatsAppMessage(userInput, uniqueUrl);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link sent successfully!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicDropdown(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No policy found with the provided information')),
        );
      }
    } catch (e) {
      print('Error querying Firestore or sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendWhatsAppMessage(String phoneNumber, String url) async {
    String message = Uri.encodeComponent("Here's your survey link: $url");
    String whatsappUrl = "https://wa.me/$phoneNumber?text=$message";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> _sendEmail(String email, String url) async {
    final Email emailMessage = Email(
      body: "Here's your survey link: $url",
      subject: 'Survey Link',
      recipients: [email],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(emailMessage);
    } catch (error) {
      print('Error sending email: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Survey App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _proceedAsSurveyor,
                  child: Text('Proceed as Surveyor', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _sendLinkToUser,
                  child: Text('Send Link to User', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                if (_showInput) ...[
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter email or phone number',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitUserInput,
                    child: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}