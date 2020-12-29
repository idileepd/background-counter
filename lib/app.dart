import 'package:flutter/material.dart';
import 'package:flutter_foreground_service_plugin/flutter_foreground_service_plugin.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  final void Function() periodicFuction;
  final SharedPreferences prefs;

  const MyApp({Key key, @required this.periodicFuction, @required this.prefs})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final box = GetStorage();

  void startCounting() async {
    await startService();
    await startTask();
  }

  void stopCounting() async {
    await stopTask();
    await stopService();
  }

  void pauseService() async {
    bool isRunning =
        await FlutterForegroundServicePlugin.isForegroundServiceRunning();
    print("Status: $isRunning");
    if (isRunning)
      await stopService();
    else
      await stopService();
  }

  void resetCounter() async {
    //stop service
    //clear storage
    //start service
    await stopTask();
    await stopService();
    // await box.write('store', 0);
    bool status = await widget.prefs.setInt('store', 0);
    print("Reset to 0 and status : $status  ");
  }

  Future<void> startService() async {
    await FlutterForegroundServicePlugin.startForegroundService(
      notificationContent: NotificationContent(
        iconName: 'ic_launcher',
        titleText: 'Task Tracking',
        color: Colors.red,
        subText: 'status',
      ),
      notificationChannelContent: NotificationChannelContent(
        id: 'counting_id',
        nameText: 'Task Tracking',
        descriptionText: 'Task Tracking',
        // lockscreenVisibility: NotificationChannelLockscreenVisibility.public,
      ),
    );
  }

  Future<void> stopService() async {
    await FlutterForegroundServicePlugin.stopForegroundService();
  }

  Future<void> startTask() async {
    await FlutterForegroundServicePlugin.startPeriodicTask(
      periodicTaskFun: widget.periodicFuction,
      period: const Duration(seconds: 1),
    );
  }

  Future<void> stopTask() async {
    await FlutterForegroundServicePlugin.stopPeriodicTask();
  }

  void checkServiceStatus() async {
    var isRunning =
        await FlutterForegroundServicePlugin.isForegroundServiceRunning();
    print(isRunning);
    var snackbar = SnackBar(
      content: Text('$isRunning'),
      duration: Duration(milliseconds: 500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                children: [
                  // TextButton(
                  //   child: Text('Start service'),
                  //   onPressed: startService,
                  // ),
                  // TextButton(
                  //   child: Text('Stop service'),
                  //   onPressed: stopService,
                  // ),
                  // TextButton(
                  //   child: Text('Is service running'),
                  //   onPressed: checkServiceStatus,
                  // ),
                  // TextButton(
                  //   child: Text('Start task'),
                  //   onPressed: startTask,
                  // ),
                  // TextButton(
                  //   child: Text('Stop task'),
                  //   onPressed: stopTask,
                  // ),
                  TextButton(
                    child: Text('Start counting'),
                    onPressed: startCounting,
                  ),
                  TextButton(
                    child: Text('Stop counting'),
                    onPressed: stopCounting,
                  ),
                  TextButton(
                    child: Text('reset counting'),
                    onPressed: resetCounter,
                  ),
                  TextButton(
                    child: Text('pasuse resume'),
                    onPressed: pauseService,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
