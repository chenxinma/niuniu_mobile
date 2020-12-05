import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:date_format/date_format.dart';

void main() {
  group('Niuniu App', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      // driver.waitFor(find.byValueKey("homework_subject_1"));
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('check homework publish date.', () async {
      await driver.tap(find.byValueKey("homework_subject_1"));
//      await driver.tap(find.byValueKey("OK"));
      // Use the `driver.getText` method to verify the counter starts at 0.
      // var text = find.byValueKey("publishDateText");

      // expect(await driver.getText(text),
      //     "作业日:   " + formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd]));
    });

    // test('increments the counter', () async {
    //   // First, tap the button.
    //   await driver.tap(buttonFinder);

    //   // Then, verify the counter text is incremented by 1.
    //   expect(await driver.getText(counterTextFinder), "1");
    // });
  });
}