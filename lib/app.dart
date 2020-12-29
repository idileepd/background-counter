import 'package:flutter/material.dart';
import 'package:flutter_foreground_service_plugin/flutter_foreground_service_plugin.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ntp/ntp.dart';

class MyApp extends StatefulWidget {
  final void Function() periodicFuction;

  const MyApp({Key key, @required this.periodicFuction}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final box = GetStorage();

  void startCounting() async {
    DateTime startDate = await NTP.now();
    await box.write('ntpStartDate', startDate.millisecondsSinceEpoch);
    await box.write('startDate', DateTime.now().millisecondsSinceEpoch);
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
    bool isRunning =
        await FlutterForegroundServicePlugin.isForegroundServiceRunning();
    if (isRunning) {
      await stopTask();
      await stopService();
      // await box.write('store', 0);
      await box.write('ntpStartDate', null);
      await box.write('startDate', null);
    }
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
    bool isRunning =
        await FlutterForegroundServicePlugin.isForegroundServiceRunning();
    if (isRunning) await FlutterForegroundServicePlugin.stopForegroundService();
  }

  Future<void> startTask() async {
    await FlutterForegroundServicePlugin.startPeriodicTask(
      periodicTaskFun: widget.periodicFuction,
      period: const Duration(seconds: 1),
    );
  }

  Future<void> stopTask() async {
    bool isRunning =
        await FlutterForegroundServicePlugin.isForegroundServiceRunning();
    if (isRunning) await FlutterForegroundServicePlugin.stopPeriodicTask();
  }

  void checkServiceStatus() async {
    bool isRunning =
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
    print("INIT");
    // box.listenKey('store', (value) {
    //   print('new key is $value');
    // });
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
