import 'package:get/get.dart';
import 'package:image/image.dart' as imageLib;
import 'package:imgs/providers/duplicate_count_provider.dart';

abstract class Hash {
  int compare(imageLib.Image img1, imageLib.Image img2, int i, int j) {
    DuplicateCountProvider controller = Get.put(DuplicateCountProvider());
    String hash1 = '';
    String hash2 = '';
    try {
      hash1 = controller.hashedFiles[i];
    } catch (_) {
      hash1 = calculate(img1);
      controller.hashedFiles.insert(i, hash1);
    }

    try {
      hash2 = controller.hashedFiles[j];
    } catch (_) {
      hash2 = calculate(img2);
      controller.hashedFiles.insert(j, hash2);
    }

    // hash1 = controller.hashedFiles[i] == null
    //     ? calculate(img1)
    //     : controller.hashedFiles[i];
    // hash2 = controller.hashedFiles[j] == null
    //     ? calculate(img2)
    //     : controller.hashedFiles[j];
    int distance = 0;
    print('Hash1 : ${hash1.length}, Hash2 : ${hash2.length}');
    if (hash1.length > hash2.length) {
      int hashDifference = hash1.length - hash2.length;
      if (hashDifference > 20) {
        distance = 5;
      } else {
        for (int i = 0; i < hash2.length; i++) {
          if (hash1[i] != hash2[i]) {
            distance++;
          }
        }
      }
    } else {
      int hashDifference = hash2.length - hash1.length;
      if (hashDifference > 20) {
        distance = 5;
      } else {
        for (int i = 0; i < hash1.length; i++) {
          if (hash1[i] != hash2[i]) {
            distance++;
          }
        }
      }
    }
    // for (int i = 0; i < hash1.length; i++) {
    //   if (hash1[i] != hash2[i]) {
    //     distance++;
    //   }
    // }

    return distance;
  }

  String calculate(imageLib.Image img);
}
