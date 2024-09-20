import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'package:http_parser/http_parser.dart';
import 'dart:js' as js;


class ImageUploadService {
  static const AUTH_API_ENDPOINT = 'https://uat.iailclaimftr.com/api/V1/auth';
  static const API_ENDPOINT = 'https://uat.iailclaimftr.com/api/V1/rc';

  // Hardcoded authentication details
  static const String username = "gAAAAABfqhmdiVzoGThMkYkX1wKTlbK_yh1XLdECahns85T9XhNl7Lff3I-frOyn8gGoWSctvVTw-4woa8gkRly9RQPZz6n67w==";
  static const String password = "gAAAAABfqhmdiVzoGThMkYkX1wKTlbK_yh1XLdECahns85T9XhNl7Lff3I-frOyn8gGoWSctvVTw-4woa8gkRly9RQPZz6n67w==";

  // 1. Call the authentication API
  Future<String?> getAuthToken() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json'
    };

    final body = json.encode({
      'username': username,
      'password': password,
    });

    // Make the request here
    final response = await http.post(
      Uri.parse(AUTH_API_ENDPOINT),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      // This assumes that the token is a direct field in the response JSON.
      // Adjust as needed based on your API's response structure.
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse['access_token']);
      return jsonResponse['access_token'] as String;
    } else {
      throw Exception('Failed to authenticate.');
    }
  }

  // Future<String> saveImageAndGetPath(Uint8List imageData, String fileName) async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String path = directory.path;
  //   File imgFile = File('$path/$fileName.jpg');
  //   imgFile.writeAsBytesSync(imageData);
  //   return imgFile.path;
  // }
  MediaType detectImageMediaType(Uint8List imageData) {
    if (imageData == null || imageData.length < 8) {
      return MediaType('application', 'octet-stream');
    }

    if (imageData.sublist(0, 2) == [0xFF, 0xD8]) {
      return MediaType('image', 'jpeg');
    }

    if (imageData.sublist(0, 8).toString() ==
        '[137, 80, 78, 71, 13, 10, 26, 10]') {
      return MediaType('image', 'png');
    }

    // Add more checks for other formats if needed
    return MediaType('application', 'octet-stream');
  }

  Future<html.Blob> loadImageAsset(String assetPath) async {
    // Load asset image bytes
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();

    // Convert image bytes to Blob
    return html.Blob([bytes]);
  }

  Future<dynamic> uploadImage(Uint8List imageData) async {
    final token = await getAuthToken();
    print(token);
    Uint8List dummyImage = Uint8List.fromList(<int>[
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
      0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
      0, 0, 0, 11, 73, 68, 65, 84, 8, 215, 99, 96, 0, 0, 0, 2,
      0, 1, 226, 96, 130, 225, 0, 0, 0, 0, 73, 69, 78, 68, 174,
      66, 96, 130
    ]);

    if (kIsWeb) {
      // Web implementation using dart:html
      final blob = html.Blob([imageData]);
      final form = html.FormData();
      final Completer<Map<String, dynamic>> completer = Completer();




      String accessKey = 'd452aee4-e372-456f-a30e-77e007fdcca5';
      form.append('access_key', accessKey);
      print("access_key: $accessKey");

      String filename = 'somefilename.png';
      form.appendBlob('rc_page_1', blob, filename);
      print("rc_page_1 filename: $filename");

      // final blob2 = html.Blob([dummyImage]);
      // form.appendBlob('rc_page_2', blob2, 'dummy.png');
      // print("rc_page_2 has a dummy image.");
      final assetBlob = await loadImageAsset('assets/dummy.jpg');
      form.appendBlob('rc_page_2', assetBlob, 'somefie.png');
      print("rc_page_2 filename: somefi.png");

      final request = html.HttpRequest();
      String url = 'https://uat.iailclaimftr.com/api/V1/rc';
      request.open('POST', url);
      print("Endpoint URL: $url");

      String authToken = 'JWT $token';
      request.setRequestHeader('Authorization', authToken);
      print("Authorization Header: $authToken");
      print("gotchaaaaa");
      request.send(form);




      request.onLoadEnd.listen((event) {
        if (request.status == 200) {
          print("Uploaded! Response: ${request.responseText}");

          // Convert the response text into a map and complete the future.
          Map<String, dynamic> jsonResponse = json.decode(request.responseText!);

          completer.complete(jsonResponse);
        } else {
          print("Not uploaded! Status: ${request.status}, Reason: ${request.statusText}, Response: ${request.responseText}");

          // Complete with an error. This will make the Future return an error when awaited.
          completer.completeError("Upload failed with status: ${request.status}");
        }
      });

      request.onError.listen((event) {
        print("Error occurred: ${event}");
        completer.completeError("Error occurred during upload");
      });

      return completer.future;

    } else {
      // Mobile implementation using http package and MultipartFile
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://uat.iailclaimftr.com/api/V1/rc'));
      request.headers['Authorization'] = 'JWT $token';

      request.fields['access_key'] = 'd452aee4-e372-456f-a30e-77e007fdcca5';
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // Add other headers if required
      });

      http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
        'rc_page_1',
        imageData,
        filename: 'somefilename.png',
        contentType: MediaType('image', 'png'),
      );
      request.files.add(multipartFile);

      // If you have a second file to send, do it similarly.
      request.files.add(
          await http.MultipartFile.fromPath('rc_page_2', '/path/to/file'));

      var response = await request.send();
      if (response.statusCode == 200) {
        print("Uploaded!");
        return response;
      } else {
        print("Not uploaded!");
        return response;
      }
    }
  }
  Future<dynamic> sendRcRegNumber(String rcRegNumber) async {
    print(rcRegNumber);
    final Uri apiUrl = Uri.parse('https://kyc-api.aadhaarkyc.io/api/v1/rc/rc-full'); // Replace with your API endpoint
    String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY1MTQ3MjA3OCwianRpIjoiN2Y1ZjAzNmEtNDBlMC00NDFlLWE4NzYtMWFjMGU5YWE2OTUyIiwidHlwZSI6ImFjY2VzcyIsImlkZW50aXR5IjoiZGV2LmlhaWxAYWFkaGFhcmFwaS5pbyIsIm5iZiI6MTY1MTQ3MjA3OCwiZXhwIjoxOTY2ODMyMDc4LCJ1c2VyX2NsYWltcyI6eyJzY29wZXMiOlsicmVhZCJdfX0.Uv7arJdKKhug-6k60H4ovD1VxW1LuDLVcfX5iiKQQs4';
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Add any other headers if required by the API
      },
      body: json.encode({
        'id_number': rcRegNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('Successfully sent data to the API!');
      print(response);
      print(response.body);
      return response.body;


  } else {
      print('Failed to send data. Status code: ${response.statusCode}');
      return response.body;
    }
  }
}




    // Use that token in the headers for the subsequent API call

