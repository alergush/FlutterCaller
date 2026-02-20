package com.alergush.flutter_caller;

import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import com.alergush.flutter_caller.utils.CallEvents;
import com.alergush.flutter_caller.utils.CallMethods;
import com.alergush.flutter_caller.utils.CallServiceListener;
import com.alergush.flutter_caller.utils.CallStateManager;
import com.alergush.flutter_caller.utils.CallStatus;
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.Voice;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements CallServiceListener {
    private static final String TAG = "MainActivity";
    private static final String CHANNEL_METHODS = "com.alergush.flutter_caller/call_methods";
    private static final String CHANNEL_EVENTS = "com.alergush.flutter_caller/call_events";

    private EventChannel.EventSink eventSink;
    private CallService callService;
    private boolean isBound = false;
    private boolean shouldAnswerOnBind = false;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    private final ServiceConnection callServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName className, IBinder service) {
            CallService.LocalBinder binder = (CallService.LocalBinder) service;
            callService = binder.getService();
            isBound = true;
            callService.setListener(MainActivity.this);

            Log.d(TAG, "Service Connected");

            if (shouldAnswerOnBind) {
                callService.answerCall();
                shouldAnswerOnBind = false;
            }

            syncStateWithFlutter();
        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
            isBound = false;
            callService = null;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        processIntent(getIntent());
    }

    @Override
    protected void onDestroy() {
        executor.shutdown();
        super.onDestroy();
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        processIntent(intent);
    }

    @Override
    protected void onStart() {
        super.onStart();
        Intent intent = new Intent(this, CallService.class);
        bindService(intent, callServiceConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    protected void onStop() {
        if (isBound) {
            if (callService != null)
                callService.setListener(null);

            unbindService(callServiceConnection);
            isBound = false;
        }

        super.onStop();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_METHODS)
                .setMethodCallHandler(this::handleMethodCall);

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_EVENTS)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = events;
                        syncStateWithFlutter();
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink = null;
                    }
                });
    }

    private void handleMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            CallMethods method = CallMethods.valueOf(call.method);
            switch (method) {
                case register -> {
                    registerTwilio(call.argument("accessToken"), call.argument("fcmToken"));
                    result.success(null);
                }

                case answer -> {
                    if (isServiceReady()) {
                        callService.answerCall();
                        result.success(null);
                    }
                    else {
                        shouldAnswerOnBind = true;
                        result.success(null);
                    }
                }

                case hangup -> {
                    if (isServiceReady()) {
//                        callService.hangupCall();
                        executor.execute(() -> callService.hangupCall());
                        CallStateManager.getInstance().setCallStatus(CallStatus.IDLE, null);
                    }
                    else
                        CallStateManager.getInstance().reset();

                    syncStateWithFlutter();

                    result.success(null);
                }

                case toggleMute -> {
                    if (isServiceReady()) {
                        callService.setMute(Boolean.TRUE.equals(call.argument("isMuted")));
                        result.success(null);
                    }
                    else result.error("SERVICE_OFFLINE", null, null);
                }

                case toggleSpeaker -> {
                    if (isServiceReady()) {
                        callService.setSpeaker(Boolean.TRUE.equals(call.argument("isSpeaker")));
                        result.success(null);
                    }
                    else result.error("SERVICE_OFFLINE", null, null);
                }

                case checkCallState ->
                        result.success(CallStateManager.getInstance().toMap());

                case checkPermissions -> {
                    checkFullScreenIntentPermission();
                    result.success(null);
                }

                default -> result.notImplemented();
            }
        }
        catch (IllegalArgumentException e) {
            result.notImplemented();
        }
    }

    private void processIntent(Intent intent) {
        if (intent == null || intent.getAction() == null) return;

        if (intent.getAction().equals(CallEvents.INCOMING_CALL_ACCEPT.name())) {
            if (isServiceReady())
                callService.answerCall();
            else
                shouldAnswerOnBind = true;

            intent.setAction(null);
        }
    }

    @Override
    public void onCallStateUpdated() {
        syncStateWithFlutter();
    }

    private void syncStateWithFlutter() {
        runOnUiThread(() -> {
            if (eventSink != null) {
                eventSink.success(CallStateManager.getInstance().toMap());
            }
        });
    }

    private boolean isServiceReady() {
        return isBound && callService != null;
    }

    private void registerTwilio(String accessToken, String fcmToken) {
        Voice.register(accessToken, Voice.RegistrationChannel.FCM, fcmToken, new RegistrationListener() {
            @Override
            public void onRegistered(@NonNull String accessToken, @NonNull String fcmToken) {
                CallStateManager.getInstance().setRegistrationStatus(true, null);
                syncStateWithFlutter();
            }

            @Override
            public void onError(@NonNull RegistrationException e, @NonNull String accessToken, @NonNull String fcmToken) {
                CallStateManager.getInstance().setRegistrationStatus(true, e.getMessage());
                Log.e(TAG, "Registration Error: " + e.getMessage());
            }
        });
    }

    private void checkFullScreenIntentPermission() {
        if (Build.VERSION.SDK_INT >= 34) {
            NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            if (nm != null && !nm.canUseFullScreenIntent()) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT);
                intent.setData(Uri.parse("package:" + getPackageName()));
                startActivity(intent);
            }
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            if (isServiceReady()) {
                callService.silenceRinger();
            }
        }

        return super.onKeyDown(keyCode, event);
    }
}
