import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/screens/call_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_caller/models/call_methods.dart';
import 'package:flutter_caller/screens/home_screen.dart';
import 'package:flutter_caller/widgets/call_overlay_manager.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';

const serverBaseUrl = "http://192.168.0.150:3000/api";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const MethodChannel methodChannel = MethodChannel(
  'com.alergush.flutter_caller/call_methods',
);
const EventChannel eventChannel = EventChannel(
  'com.alergush.flutter_caller/call_events',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  String? _accessToken;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _setup();
    _initEventListener();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setup() async {
    bool permissionsGranted = await _checkPermissions();
    if (permissionsGranted) {
      await _register();
    } else {
      await methodChannel.invokeMethod('checkPermissions');
      // debugPrint("Permissions denied. App functionality limited.");
    }
  }

  Future<bool> _checkPermissions() async {
    var micStatus = await Permission.microphone.status;
    var notifStatus = await Permission.notification.status;

    if (!micStatus.isGranted || !notifStatus.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.notification,
        Permission.phone,
        if (Platform.isAndroid) Permission.bluetoothConnect,
      ].request();

      return statuses[Permission.microphone] == PermissionStatus.granted &&
          statuses[Permission.notification] == PermissionStatus.granted;
    }
    return true;
  }

  Future<void> _register() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM Token: $fcmToken");

      final url = Uri.parse('$serverBaseUrl/voice/token');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _accessToken = data['token'];
        debugPrint("Twilio Access Token received");

        if (fcmToken != null && _accessToken != null) {
          await methodChannel.invokeMethod(CallMethods.register, {
            'accessToken': _accessToken,
            'fcmToken': fcmToken,
          });
        }
      } else {
        debugPrint('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
    }
  }

  void _initEventListener() {
    _eventSubscription = eventChannel.receiveBroadcastStream().listen(
      _onEventReceived,
      onError: (dynamic error) {
        debugPrint('Event Stream Error: $error');
      },
    );
  }

  void _onEventReceived(dynamic event) {
    final data = event as Map<dynamic, dynamic>;

    debugPrint("FLUTTER: Received Event from Java: $data");

    final stateChanged = ref.read(callStateProvider.notifier).syncWithMap(data);

    if (stateChanged) {
      final statusStr = data['callStatus'] ?? "idle";

      final isIdle =
          statusStr.toLowerCase() == CallStatus.idle.name ||
          statusStr.toLowerCase() == CallStatus.disconnected.name;

      if (!isIdle) {
        bool isCallScreenOpen = false;
        navigatorKey.currentState?.popUntil((route) {
          if (route.settings.name == 'call_screen') {
            isCallScreenOpen = true;
          }
          return true;
        });

        if (!isCallScreenOpen) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            'call_screen',
            (route) => route.settings.name != 'call_screen',
          );
        }
      } else {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Caller',
      routes: {
        'call_screen': (context) => const CallScreen(),
      },
      home: const Scaffold(
        backgroundColor: Color.fromARGB(255, 38, 38, 38),
        body: CallOverlayManager(child: HomeScreen()),
      ),
    );
  }
}
