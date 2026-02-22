import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caller/models/tokens.dart';
import 'package:flutter_caller/providers/auth_state_provider.dart';
import 'package:flutter_caller/providers/operator_credentials_provider.dart';
import 'package:flutter_caller/screens/auth_screen.dart';
import 'package:flutter_caller/screens/sign_up_screen.dart';
import 'package:flutter_caller/screens/splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/screens/call_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_caller/models/call_methods.dart';
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

class _AppState extends ConsumerState<App> {
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _initEventListener();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _initEventListener() {
    _eventSubscription = eventChannel.receiveBroadcastStream().listen(
      _onEventReceived,
      onError: (dynamic error) {
        debugPrint('Event Stream Error: $error');
      },
    );
  }

  Future<void> _setup() async {
    bool permissionsGranted = await _checkPermissions();
    if (permissionsGranted) {
      await _register();
    } else {
      await methodChannel.invokeMethod(CallMethods.checkPermissions);
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

      debugPrint("FCM Token received");

      final url = Uri.parse('$serverBaseUrl/voice/token');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        String? accessToken = data['token'];

        debugPrint("Twilio Access Token received");

        final String? operatorId = data['operatorId'];

        debugPrint("operatorId: $operatorId");

        if (fcmToken != null && accessToken != null && operatorId != null) {
          await methodChannel.invokeMethod(CallMethods.register, {
            'accessToken': accessToken,
            'fcmToken': fcmToken,
            'operatorId': operatorId,
          });

          ref
              .read(operatorCredentialsProvider.notifier)
              .set(
                OperatorCredentials(
                  twilioAccessToken: accessToken,
                  fcmToken: fcmToken,
                  operatorId: operatorId,
                ),
              );
        }
      } else {
        debugPrint('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
    }
  }

  void _onEventReceived(dynamic event) {
    final data = event as Map<dynamic, dynamic>;

    debugPrint("${DateTime.now()} FLUTTER: Received Event from Java: $data");

    final providerState = ref.read(callStateProvider);
    final wasMinimized = providerState.callScreenState.isMinimized;
    final isFirstConnection = providerState.isFirstConnection;

    final stateChanged = ref.read(callStateProvider.notifier).syncWithMap(data);

    if (stateChanged) {
      final statusStr = data['callStatus'] ?? CallStatus.idle.name;

      final status = CallStatus.values.firstWhere(
        (e) => e.name == statusStr.toLowerCase(),
        orElse: () => CallStatus.idle,
      );

      final isIdle = status == CallStatus.idle;

      if (status == CallStatus.connected && isFirstConnection) {
        HapticFeedback.mediumImpact();
      }

      if (!isIdle) {
        if (!wasMinimized) {
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
        }
      } else {
        navigatorKey.currentState?.popUntil((route) {
          if (route.settings.name == 'call_screen') {
            return false;
          }
          return true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) async {
      if (next is AsyncData<User?>) {
        final user = next.value;
        final credentials = ref.read(operatorCredentialsProvider);

        if (user != null) {
          if (credentials == null) {
            try {
              await _setup();
            } catch (e) {
              debugPrint("Setup Error: $e");
            }
          }
        } else {
          if (credentials != null) {
            try {
              await methodChannel.invokeMethod(CallMethods.unregister, {
                'accessToken': credentials.twilioAccessToken,
                'fcmToken': credentials.fcmToken,
              });

              ref.read(operatorCredentialsProvider.notifier).clear();
              ref.invalidate(callStateProvider);
            } catch (e) {
              debugPrint("Unregistration Error: $e");
            }
          }
        }
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Caller',
      routes: {
        'call_screen': (context) => const CallScreen(),
        '/auth_screen': (context) => const AuthScreen(),
        '/sign_up_screen': (context) => const SignUpScreen(),
      },
      home: const Scaffold(
        // backgroundColor: Color.fromARGB(255, 38, 38, 38),
        body: CallOverlayManager(child: SplashScreen()),
      ),
    );
  }
}
