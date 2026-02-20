package com.alergush.flutter_caller;

import android.app.Notification;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ServiceInfo;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.media.ToneGenerator;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.ProcessLifecycleOwner;

import com.alergush.flutter_caller.utils.CallServiceListener;
import com.alergush.flutter_caller.utils.CallStateManager;
import com.alergush.flutter_caller.utils.CallEvents;
import com.alergush.flutter_caller.utils.CallStatus;
import com.alergush.flutter_caller.utils.NotificationHelper;
import com.twilio.audioswitch.AudioDevice;
import com.twilio.audioswitch.AudioSwitch;
import com.twilio.voice.Call;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;

import java.time.LocalDate;

public class CallService extends Service {
    private static final String TAG = "CallService";

    private AudioSwitch audioSwitch;
    private MediaPlayer ringtonePlayer;
    private Vibrator vibrator;
    private ToneGenerator toneGenerator;
    private Runnable soundRunnable;
    private final Handler soundHandler = new Handler(Looper.getMainLooper());
    private CallServiceListener listener;

    private boolean isRinging = false;

    private static final int reconnectingToneGeneratorVolume = 60;

    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        public CallService getService() {
            return CallService.this;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    public void setListener(CallServiceListener listener) {
        this.listener = listener;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        audioSwitch = new AudioSwitch(getApplicationContext());

        audioSwitch.start((audioDevices, audioDevice) -> {
            Log.d(TAG, "Audio device changed: " + audioDevice.getName());
            return null;
        });

        NotificationHelper.getInstance(this);
    }

    @Override
    public void onDestroy() {
        if (audioSwitch != null) {
            audioSwitch.stop();
        }

        stopRinging();
        stopSound();

        super.onDestroy();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null || intent.getAction() == null)
            return START_NOT_STICKY;

        CallEvents action;

        try {
            action = CallEvents.valueOf(intent.getAction());
        }
        catch (IllegalArgumentException ex) {
            Log.d(TAG, "onStartCommand() Unrecognized Action: " + intent.getAction());
            return START_NOT_STICKY;
        }

        Log.d(TAG, "onStartCommand() Action received: " + action);

        switch (action) {
            case INCOMING_CALL:
                startRinging();
                processIncomingCall();
                break;

            case CANCEL_INCOMING_CALL:
                stopRinging();
                manualReset();
                break;

            case INCOMING_CALL_DECLINE, HANGUP_CALL:
                stopRinging();
                hangupCall();
                break;
        }

        return START_NOT_STICKY;
    }

    private void processIncomingCall() {
        CallStateManager callStateManager = CallStateManager.getInstance();
        CallInvite activeCallInvite = callStateManager.getActiveCallInvite();

        if (activeCallInvite == null) return;

        callStateManager.setCallStatus(CallStatus.RINGING, null);
        callStateManager.setCallerPhone(activeCallInvite.getFrom());

        Notification incomingCallNotification;

        if (isAppInForeground()) {
            incomingCallNotification = NotificationHelper.getInstance(this)
                    .createIncomingCallNotification(
                    NotificationHelper.DEF_PRIORITY_CHANNEL_ID,
                    activeCallInvite.getFrom(),
                    NotificationCompat.PRIORITY_DEFAULT
            );
        }
        else {
            incomingCallNotification = NotificationHelper.getInstance(this)
                    .createIncomingCallNotification(
                    NotificationHelper.MAX_PRIORITY_CHANNEL_ID,
                    activeCallInvite.getFrom(),
                    NotificationCompat.PRIORITY_MAX
            );
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                    NotificationHelper.CALL_NOTIFICATION_ID,
                    incomingCallNotification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE
            );
        }
        else {
            startForeground(NotificationHelper.CALL_NOTIFICATION_ID, incomingCallNotification);
        }

        if (listener != null) {
            listener.onCallStateUpdated();
        }
    }

    // Call Methods

    public void answerCall() {
        CallInvite activeCallInvite = CallStateManager.getInstance().getActiveCallInvite();

        if (activeCallInvite == null) return;

        stopRinging();

        CallStateManager callStateManager = CallStateManager.getInstance();

        callStateManager.setActiveCallInvite(null);
        callStateManager.setCallStatus(CallStatus.CONNECTING, null);
        callStateManager.setIsFirstConnection(true);

        if (listener != null) {
            listener.onCallStateUpdated();
        }

        try {
            Call activeCall = activeCallInvite.accept(this, callListener);

            CallStateManager.getInstance().setActiveCall(activeCall);

            Notification inCallNotification = NotificationHelper.getInstance(this)
                    .createInCallNotification(
                        NotificationHelper.DEF_PRIORITY_CHANNEL_ID, activeCall.getFrom());

            startForeground(
                    NotificationHelper.CALL_NOTIFICATION_ID,
                    inCallNotification,
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            );
        }
        catch (Exception e) {
            Log.e(TAG, "answerCall() Failed to answer call", e);
        }
    }

    public void hangupCall() {
        CallInvite activeCallInvite = CallStateManager.getInstance().getActiveCallInvite();
        Call activeCall = CallStateManager.getInstance().getActiveCall();

        CallStateManager.getInstance().setLocallyDisconnected(true);

        stopRinging();

        if (activeCallInvite != null) {
            activeCallInvite.reject(getApplicationContext());
            manualReset();
        }
        else if (activeCall != null) {
            activeCall.disconnect();
        }
        else {
            manualReset();
        }
    }

    public void setSpeaker(boolean on) {
        Call activeCall = CallStateManager.getInstance().getActiveCall();

        if (activeCall == null) return;

        audioSwitch.selectDevice(audioSwitch.getAvailableAudioDevices().stream()
                .filter(d -> d instanceof AudioDevice.Speakerphone == on)
                .findFirst().orElse(null)
        );

        CallStateManager.getInstance().setSpeaker(on);

        if (listener != null) {
            listener.onCallStateUpdated();
        }
    }

    public void setMute(boolean mute) {
        Call activeCall = CallStateManager.getInstance().getActiveCall();

        if (activeCall == null) return;

        activeCall.mute(mute);
        CallStateManager.getInstance().setMute(mute);

        if (listener != null) {
            listener.onCallStateUpdated();
        }
    }

    // Call Listener

    private final Call.Listener callListener = new Call.Listener() {
        @Override
        public void onRinging(@NonNull Call call) {
            CallStateManager callStateManager = CallStateManager.getInstance();

            callStateManager.setCallStatus(CallStatus.RINGING, null);

            if (listener != null) {
                listener.onCallStateUpdated();
            }
        }

        @Override
        public void onConnected(@NonNull Call call) {
            CallStateManager callStateManager = CallStateManager.getInstance();

            callStateManager.setCallStatus(CallStatus.CONNECTED, null);
            callStateManager.setCallStartTime(System.currentTimeMillis());

            if (listener != null) {
                listener.onCallStateUpdated();
            }

            callStateManager.setIsFirstConnection(false);

            audioSwitch.activate();
        }

        @Override
        public void onConnectFailure(@NonNull Call call, @NonNull CallException e) {
            stopSound();

            CallStateManager callStateManager = CallStateManager.getInstance();

            callStateManager.setCallStatus(CallStatus.DISCONNECTED, e.getMessage());
            callStateManager.setActiveCall(null);
            callStateManager.setIsFirstConnection(false);

            if (listener != null) {
                listener.onCallStateUpdated();
            }

            startSound(ToneGenerator.TONE_PROP_PROMPT, 250, 500, 2);
            vibrate(new long[]{ 0, 250, 200, 250 }, false);

            stopForeground(STOP_FOREGROUND_REMOVE);

            delayedReset();
        }

        @Override
        public void onDisconnected(@NonNull Call call, @Nullable CallException e) {
            stopSound();

            Log.e(TAG, LocalDate.now() + " onDisconnected()");

            CallStateManager callStateManager = CallStateManager.getInstance();

            callStateManager.setActiveCall(null);

            boolean localHangup = callStateManager.isLocallyDisconnected();

            if (e != null) {
                callStateManager.setCallStatus(CallStatus.DISCONNECTED, e.getMessage());

                startSound(ToneGenerator.TONE_PROP_PROMPT, 250, 500, 2);
                vibrate(new long[]{ 0, 250, 200, 250 }, false);

                delayedReset();
            }
            else if (localHangup) {
                callStateManager.reset();
                manualReset();
                return;
            }
            else {
                callStateManager.setCallStatus(CallStatus.DISCONNECTED, null);

                startSound(ToneGenerator.TONE_PROP_PROMPT, 250, 500, 2);
                vibrate(new long[]{ 0, 250, 200, 250 }, false);

                delayedReset();
            }

            if (listener != null) {
                listener.onCallStateUpdated();
            }

            stopForeground(STOP_FOREGROUND_REMOVE);
        }

        @Override
        public void onReconnecting(@NonNull Call call, @NonNull CallException e) {
            CallStateManager callStateManager = CallStateManager.getInstance();

            callStateManager.setCallStatus(CallStatus.RECONNECTING, null);

            if (listener != null) {
                listener.onCallStateUpdated();
            }

            startSound(ToneGenerator.TONE_PROP_BEEP, 200, 1500, Integer.MAX_VALUE);
        }

        @Override
        public void onReconnected(@NonNull Call call) {
            CallStateManager callStateManager = CallStateManager.getInstance();

            callStateManager.setCallStatus(CallStatus.CONNECTED, null);

            if (listener != null) {
                listener.onCallStateUpdated();
            }

            stopSound();
        }
    };

    // Help Methods

    private boolean isAppInForeground() {
        return ProcessLifecycleOwner.get().getLifecycle()
                .getCurrentState().isAtLeast(Lifecycle.State.STARTED);
    }

    private void stopForegroundService() {
        audioSwitch.deactivate();
        stopForeground(STOP_FOREGROUND_REMOVE);
        stopSelf();
    }

    private void manualReset() {
        CallStateManager.getInstance().reset();

        if (listener != null) {
            listener.onCallStateUpdated();
        }

        stopForegroundService();
    }

    // Sound

    public void silenceRinger() {
        isRinging = false;

        if (ringtonePlayer != null) {
            if (ringtonePlayer.isPlaying()) {
                ringtonePlayer.stop();
            }
            ringtonePlayer.release();
            ringtonePlayer = null;
        }

        if (vibrator != null) {
            vibrator.cancel();
            vibrator = null;
        }
    }

    private final BroadcastReceiver volumeReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if ("android.media.VOLUME_CHANGED_ACTION".equals(intent.getAction())) {
                if (isRinging) {
                    silenceRinger();
                }
            }
        }
    };

    private void startRinging() {
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

        if (audioManager == null) return;

        int ringerMode = audioManager.getRingerMode();

        if (ringerMode == AudioManager.RINGER_MODE_NORMAL) {
            try {
                Uri ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
                ringtonePlayer = new MediaPlayer();
                ringtonePlayer.setDataSource(this, ringtoneUri);

                ringtonePlayer.setAudioAttributes(new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build());

                ringtonePlayer.setLooping(true);
                ringtonePlayer.prepare();
                ringtonePlayer.start();
            }
            catch (Exception e) {
                Log.e(TAG, "Ringtone Play Error: " + e.getMessage());
            }
        }

        vibrate(new long[]{ 0, 1000, 1000 }, true);

        isRinging = true;

        try {
            IntentFilter filter = new IntentFilter("android.media.VOLUME_CHANGED_ACTION");

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(volumeReceiver, filter, Context.RECEIVER_EXPORTED);
            }
            else {
                registerReceiver(volumeReceiver, filter);
            }
        }
        catch (Exception e) {
            Log.e(TAG, "Volume Receiver Registration Error: " + e.getMessage());
        }
    }

    private void stopRinging() {
        silenceRinger();

        try {
            unregisterReceiver(volumeReceiver);
        }
        catch (Exception ignored) { }
    }

    private void startSound(int toneType, int durationMs, int delayMs, int repeat) {
        stopSound();

        try {
            toneGenerator = new ToneGenerator(
                    AudioManager.STREAM_VOICE_CALL,
                    reconnectingToneGeneratorVolume);

            soundRunnable = new Runnable() {
                int currentCount = 0;

                @Override
                public void run() {
                    if (toneGenerator != null) {
                        toneGenerator.startTone(toneType, durationMs);

                        currentCount++;

                        if (repeat == Integer.MAX_VALUE || currentCount < repeat) {
                            soundHandler.postDelayed(this, delayMs);
                        }
                    }
                }
            };

            soundHandler.post(soundRunnable);
        }
        catch (Exception e) {
            Log.e(TAG, "Play Reconnecting Sound Error: " + e.getMessage());
        }
    }

    private void stopSound() {
        if (soundRunnable != null) {
            soundHandler.removeCallbacks(soundRunnable);
            soundRunnable = null;
        }

        if (toneGenerator != null) {
            toneGenerator.release();
            toneGenerator = null;
        }
    }

    private void vibrate(long[] pattern, boolean repeat) {
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

        if (audioManager == null) return;

        int ringerMode = audioManager.getRingerMode();

        if (ringerMode == AudioManager.RINGER_MODE_NORMAL ||
                ringerMode == AudioManager.RINGER_MODE_VIBRATE) {
            vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

            if (vibrator != null) {
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, repeat ? 1 : -1));
            }
        }
    }

    private void delayedReset() {
        new android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(() -> {
            CallStateManager.getInstance().reset();

            if (listener != null) {
                listener.onCallStateUpdated();
            }

            stopForegroundService();
        }, 2000);
    }
}
