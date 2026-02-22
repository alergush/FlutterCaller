package com.alergush.flutter_caller;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alergush.flutter_caller.utils.CallStateManager;
import com.alergush.flutter_caller.utils.CallEvents;
import com.alergush.flutter_caller.utils.CallStatus;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.CancelledCallInvite;
import com.twilio.voice.MessageListener;
import com.twilio.voice.Voice;

import java.util.Map;

public class CallFirebaseMessagingService extends FirebaseMessagingService {
    private static final String TAG = "CallFirebaseMessagingService";

    // TODO
    @Override
    public void onNewToken(@NonNull String token) {
        super.onNewToken(token);
        Log.d(TAG, "onNewToken() Refreshed Token: " + token);
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        Log.d(TAG, "onMessageReceived() Message received from: " + remoteMessage.getFrom());

        Map<String, String> data = remoteMessage.getData();

        if (data.isEmpty()) return;

        String twiTo = data.get("twi_to");

        if (twiTo == null) {
            Log.e(TAG, "twi_to is null");
            return;
        }

        String intendedOperatorId;

        String[] twiToParts = twiTo.split(":");

        if (twiToParts.length < 2) {
            Log.e(TAG, "twi_to incorrect format: " + twiTo);
            return;
        }

        intendedOperatorId = twiToParts[1];

        SharedPreferences sharedPreferences = getSharedPreferences("prefs", Context.MODE_PRIVATE);

        String loggedInOperatorId = sharedPreferences.getString("operatorId", null);

        if (loggedInOperatorId == null || !loggedInOperatorId.equals(intendedOperatorId)) {
            Log.w(TAG, "Call drop: No operator is logged on this device.");
            return;
        }

        Voice.handleMessage(this, data, messageListener);
    }

    private final MessageListener messageListener = new MessageListener() {
        @Override
        public void onCallInvite(@NonNull CallInvite callInvite) {
            Log.d(TAG, "onCallInvite() Incoming Call from: " + callInvite.getFrom());

            CallStateManager callStateManager = CallStateManager.getInstance();

            Log.i(TAG, "callInvite.getTo() " + callInvite.getTo());

            if (callStateManager.getCallStatus() != CallStatus.IDLE &&
                    callStateManager.getCallStatus() != CallStatus.DISCONNECTED) {
                Log.w(TAG, "onCallInvite() Incoming Call rejected - another call in process"
                        + callInvite.getFrom());
                callInvite.reject(getApplicationContext());
                return;
            }

            callStateManager.setActiveCallInvite(callInvite);

            Intent incomingCallIntent = new Intent(
                    CallFirebaseMessagingService.this, CallService.class);
            incomingCallIntent.setAction(CallEvents.INCOMING_CALL.name());

            startForegroundService(incomingCallIntent);
        }

        @Override
        public void onCancelledCallInvite(@NonNull CancelledCallInvite cancelledCallInvite,
                                          @Nullable CallException callException) {
            if (callException != null) {
                Log.d(TAG, "onCancelledCallInvite() CallException: " +
                        callException.getMessage());
            }

            Log.d(TAG, "onCancelledCallInvite() Cancelled Incoming Call from " +
                    cancelledCallInvite.getFrom());

            CallInvite activeInvite = CallStateManager.getInstance().getActiveCallInvite();

            if (activeInvite != null &&
                    !cancelledCallInvite.getCallSid().equals(activeInvite.getCallSid())) {
                return;
            }

            Intent cancelIncomingCallIntent = new Intent(
                    CallFirebaseMessagingService.this, CallService.class);
            cancelIncomingCallIntent.setAction(CallEvents.CANCEL_INCOMING_CALL.name());

            startForegroundService(cancelIncomingCallIntent);
        }
    };
}
