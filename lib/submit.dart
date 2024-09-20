// import 'dart:convert';
// import 'package:damagedetection/helpers/constants.dart';
// import 'package:damagedetection/helpers/UploadSuccess.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// void submitInspection(
//     {String frontSide = "",
//       String frontSideTimeStamp = "",
//       String frontSideLocation = "",
//       String frontRightHandSide = "",
//       String frontRightHandSideTimeStamp = "",
//       String frontRightHandSideLocation = "",
//       String driverSide = "",
//       String driverSideTimeStamp = "",
//       String driverSideLocation = "",
//       String rearRightHandSide = "",
//       String rearRightHandSideTimeStamp = "",
//       String rearRightHandSideLocation = "",
//       String rearSide = "",
//       String rearSideTimeStamp = "",
//       String rearSideLocatiom = "",
//       String rearLeftHandSide = "",
//       String rearLeftHandSideTimeStamp = "",
//       String rearLeftHandSideLocation = "",
//       String passengerSide = "",
//       String passengerSideTimeStamp = "",
//       String passengerSideLocation = "",
//       String frontLeftHandSide = "",
//       String frontLeftHandSideTimeStamp = "",
//       String frontLeftHandSideLocation = "",
//       String engineCompart = "",
//       String engineCompartTimeStamp = "",
//       String engineCompartLocation = "",
//       String chassisNo = "",
//       String chassisNoTimeStamp = "",
//       String chassisNoLocation = "",
//       String odometerCar = "",
//       String odometerCarTimeStamp = "",
//       String odometerCarLocation = "",
//       String regCert = "",
//       String regCertTimeStamp = "",
//       String regCertLocation = "",
//       String inspectionCert = "",
//       String inspectionCertTimeStamp = "",
//       String inspectionCertLocation = "",
//       String optional1 = "",
//       String optional1TimeStamp = "",
//       String optional1Location = "",
//       String optional2 = "",
//       String optional2TimeStamp = "",
//       String optional2Location = ""}) async {
//
//   print(DateTime.now().toString());
//
//   print(frontSideLocation);
//
//   print(frontSideTimeStamp);
//
//   print(frontRightHandSideLocation);
//
//   print(frontRightHandSideTimeStamp);
//   print(driverSideLocation);
//   print(driverSideTimeStamp);
//   print(rearRightHandSideLocation);
//
//   print(rearRightHandSideTimeStamp);
//
//   print(rearSideLocatiom);
//
//   print(rearSideTimeStamp);
//
//   print(rearLeftHandSideLocation);
//
//   print(rearLeftHandSideTimeStamp);
//
//   print(passengerSideLocation);
//
//   print(passengerSideTimeStamp);
//
//   print(frontLeftHandSideLocation);
//
//   print(frontLeftHandSideTimeStamp);
//
//   print(engineCompartLocation);
//
//   print(engineCompartTimeStamp);
//
//   print(chassisNoLocation);
//
//   print(chassisNoTimeStamp);
//
//   print(odometerCarLocation);
//
//   print(odometerCarTimeStamp);
//
//   print(regCertLocation);
//
//   print(regCertLocation);
//   var headers = {
//     'Authorization': 'JWT $jwt',
//     'User-Agent': 'PostmanRuntime/7.29.0',
//     'Content-Type': 'multipart/form-data;'
//   };
//   var request = http.MultipartRequest('POST',
//       Uri.parse('https://uatmotorinspection.mahindrainsure.com/mibl/upload'));
//   request.fields.addAll({
//     'BREAKIN_ID': breakinID,
//     'MOBILE_NO': mobileNo,
//     'TIME_STAMP': DateTime.now().toString(),
//     'INSURANCE_COMPANY': ic,
//     'FrontSideLoc': frontSideLocation,
//     'FrontSideTime': frontSideTimeStamp,
//     'FrontRightHandSideLoc': frontRightHandSideLocation,
//     'FrontRightHandSideTime': frontRightHandSideTimeStamp,
//     'DriverSideLoc': driverSideLocation,
//     'DriverSideTime': driverSideTimeStamp,
//     'RearRightHandSideLoc': rearRightHandSideLocation,
//     'RearRightHandSideTime': rearRightHandSideTimeStamp,
//     'RearSideLoc': rearSideLocatiom,
//     'RearSideTime': rearSideTimeStamp,
//     'RearLeftHandSideLoc': rearLeftHandSideLocation,
//     'RearLeftHandSideTime': rearLeftHandSideTimeStamp,
//     'PassengerSideLoc': passengerSideLocation,
//     'PassengerSideTime': passengerSideTimeStamp,
//     'FrontLeftHandSideLoc': frontLeftHandSideLocation,
//     'FrontLeftHandSideTime': frontLeftHandSideTimeStamp,
//     'EngineCompartLoc': engineCompartLocation,
//     'EngineCompartTime': engineCompartTimeStamp,
//     'ChassisNoLoc': chassisNoLocation,
//     'ChassisNoTime': chassisNoTimeStamp,
//     'OdometerCarLoc': odometerCarLocation,
//     'OdometerCarTime': odometerCarTimeStamp,
//     'RegCertLoc': regCertLocation,
//     'RegCertTime': regCertTimeStamp,
//   });
//
//   request.files.add(await http.MultipartFile.fromPath('FrontSide', frontSide));
//   request.files.add(await http.MultipartFile.fromPath(
//       'FrontRightHandSide', frontRightHandSide));
//   request.files
//       .add(await http.MultipartFile.fromPath('DriverSide', driverSide));
//   request.files.add(await http.MultipartFile.fromPath(
//       'RearRightHandSide', rearRightHandSide));
//   request.files.add(await http.MultipartFile.fromPath('RearSide', rearSide));
//   request.files.add(
//       await http.MultipartFile.fromPath('RearLeftHandSide', rearLeftHandSide));
//   request.files
//       .add(await http.MultipartFile.fromPath('PassengerSide', passengerSide));
//   request.files.add(await http.MultipartFile.fromPath(
//       'FrontLeftHandSide', frontLeftHandSide));
//   request.files
//       .add(await http.MultipartFile.fromPath('EngineCompart', engineCompart));
//   request.files.add(await http.MultipartFile.fromPath('ChassisNo', chassisNo));
//   request.files
//       .add(await http.MultipartFile.fromPath('OdometerCar', odometerCar));
//   request.files.add(await http.MultipartFile.fromPath('RegCert', regCert));
//   if (inspectionCert != "") {
//     request.files.add(
//         await http.MultipartFile.fromPath('InspectionCert', inspectionCert));
//     request.fields.addAll({
//       'InspectionCertLoc': inspectionCertLocation,
//       'InspectionCertTime': inspectionCertTimeStamp
//     });
//   }
//   if (optional1 != "") {
//     request.files
//         .add(await http.MultipartFile.fromPath('Optional1', optional1));
//   }
//   if (optional2 != "") {
//     request.files
//         .add(await http.MultipartFile.fromPath('Optional2', optional2));
//   }
//
//   request.headers.addAll(headers);
//
//   http.StreamedResponse response = await request.send();
//
//   if (response.statusCode == 200) {
//     print("Uploaded");
//     print(await response.stream.bytesToString());
//     Get.back();
//     Get.to(UploadSuccess(pospName));
//   } else {
//     print(response.reasonPhrase);
//     print("Not Uploaded//////////");
//     print(await response.stream.bytesToString());
//     print(response.statusCode);
//   }
// }
