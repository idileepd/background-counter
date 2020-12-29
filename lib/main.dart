import 'package:bgc/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_service_plugin/flutter_foreground_service_plugin.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitHours = twoDigits(duration.inHours);

  if (twoDigitMinutes == '00')
    return '$twoDigitSeconds'; // show only seconds
  else if (twoDigitHours == '00')
    return "$twoDigitMinutes:$twoDigitSeconds"; //show only min:sec
  else
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds"; //show hours:min:sec
}

void periodicTaskFun() {
  // final box = GetStorage();
  FlutterForegroundServicePlugin.executeTask(() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    // int seconds = box.read('store') ?? 0;
    int seconds = _prefs.getInt('store') ?? 0;
    // print("Refershed task: $seconds");
    int incSeconds = seconds + 1;
    // await box.write('store', incSeconds);
    bool status = await _prefs.setInt('store', incSeconds);
    print("Set status: $status  val:$incSeconds");
    // this will refresh the notification content each time the task is fire
    // if you want to refresh the notification content too each time
    // so don't set a low period duration because android isn't handling it very well
    String duration = printDuration(Duration(seconds: incSeconds));
    await FlutterForegroundServicePlugin.refreshForegroundServiceContent(
      notificationContent: NotificationContent(
        iconName: 'ic_launcher',
        titleText: incSeconds.toString(),
        bodyText: duration,
        color: Colors.red,
        // subText: 'Counting',
        // titleText: 'You are till: ${DateTime.now().second.toString()}',
        // bodyText: 'C:$x',
        // bodyText: '${DateTime.now().second.toString()}',
        // subText: 'subText',
        // enableSound: true,
        // enableVibration: true,
      ),
    );
  });
}

void main() async {
  // await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    prefs.getInt('store');
  } catch (e) {
    bool status = await prefs.setInt('store', 0);
    print("Set status: $status  val: 0");
  }
  runApp(MyApp(periodicFuction: periodicTaskFun, prefs: prefs));
}
