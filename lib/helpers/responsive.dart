import 'package:get/get.dart';

double ResWidth(val) {
  return (Get.size.width * val) / 360;
}

int ResIntWidth(val) {
  return int.parse(((Get.size.width * val) / 360).toString());
}

double ResHeight(val) {
  return (Get.size.width * val) / 640;
}

int ResIntHeight(val) {
  return int.parse(((Get.size.width * val) / 640).toString());
}
