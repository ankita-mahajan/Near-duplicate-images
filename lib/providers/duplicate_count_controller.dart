import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DuplicateCountController extends GetxController {
  int exactDuplicateCount = 0;
  int nearDuplicateCount = 0;

  incrementExact() => exactDuplicateCount++;

  incrementNear() => nearDuplicateCount;
}
