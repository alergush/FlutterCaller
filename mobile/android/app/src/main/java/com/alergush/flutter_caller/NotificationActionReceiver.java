package com.alergush.flutter_caller;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.alergush.flutter_caller.utils.CallEvents;

public class NotificationActionReceiver extends BroadcastReceiver {
    private static final String TAG = "ActionReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (context == null || intent == null || intent.getAction() == null) return;

        CallEvents action;

        try {
            action = CallEvents.valueOf(intent.getAction());
        }
        catch (IllegalArgumentException ex) {
            Log.d(TAG, "onReceive() Unrecognized notification action: " + intent.getAction());
            return;
        }

        Log.d(TAG, "onReceive() Received notification action: " + action);

        Intent serviceIntent = new Intent(context, CallService.class);
        serviceIntent.setAction(action.name());
        context.startForegroundService(serviceIntent);
    }
}
