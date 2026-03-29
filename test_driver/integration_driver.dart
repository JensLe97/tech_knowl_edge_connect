import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

// flutter drive \
//  --driver=test_driver/integration_driver.dart \
//  --target=integration_test/app_test.dart \
//  -d "iPhone 14 Plus" \
//  --dart-define=TEST_EMAIL=<email> \
//  --dart-define=TEST_PASS=<password> \
//  --dart-define=DEVICE_NAME="iPhone 14 Plus"
// flutter drive \
//  --driver=test_driver/integration_driver.dart \
//  --target=integration_test/app_test.dart -d emulator-5554
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes,
        [Map<String, Object?>? args]) async {
      // Create a "screenshots" directory at the root of your project
      final File image = File('screenshots/$screenshotName.png');

      // Ensure the directory exists
      image.parent.createSync(recursive: true);

      // Write the image bytes to your computer
      image.writeAsBytesSync(screenshotBytes);

      // Return true to indicate the screenshot was successfully processed
      return true;
    },
  );
}
