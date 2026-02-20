package com.alergush.flutter_caller.utils;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import androidx.core.app.NotificationCompat;
import androidx.core.app.Person;

import com.alergush.flutter_caller.MainActivity;
import com.alergush.flutter_caller.NotificationActionReceiver;

public class NotificationHelper {
//    private static final String TAG = "NotificationHelper";

    public static final String DEF_PRIORITY_CHANNEL_ID = "def_priority_call_service_channel";
    public static final String MAX_PRIORITY_CHANNEL_ID = "max_priority_call_service_channel";
    public static final int CALL_NOTIFICATION_ID = 101;

    private final Context context;
    private final NotificationManager notificationManager;

    private static NotificationHelper INSTANCE;

    private NotificationHelper(Context context) {
        this.context = context.getApplicationContext();
        this.notificationManager = (NotificationManager)
                this.context.getSystemService(Context.NOTIFICATION_SERVICE);

        createDefPriorityNotificationChannel();
        createMaxPriorityNotificationChannel();
    }

    public static synchronized NotificationHelper getInstance(Context context) {
        if (INSTANCE == null) {
            INSTANCE = new NotificationHelper(context);
        }
        return INSTANCE;
    }

    public void createNotificationChannel(NotificationChannelSettings settings) {
        NotificationChannel channel = new NotificationChannel(settings.id, settings.name,
                settings.importance);

        channel.setDescription(settings.description);

        channel.setSound(settings.sound, settings.audioAttributes);
        channel.enableVibration(settings.enableVibration);

        notificationManager.createNotificationChannel(channel);
    }

    private void createDefPriorityNotificationChannel() {
        String defPriorityChannelName = "Default Priority Channel";
        String defPriorityChannelDescription = "Default Priority Channel Description";
        int defPriorityChannelImportance = android.app.NotificationManager.IMPORTANCE_DEFAULT;
        boolean defPriorityChannelEnableVibration = false;

        NotificationChannelSettings defPriorityChannelSettings = new NotificationChannelSettings(
                DEF_PRIORITY_CHANNEL_ID, defPriorityChannelName, defPriorityChannelDescription,
                defPriorityChannelImportance, defPriorityChannelEnableVibration,
                null, null
        );

        createNotificationChannel(defPriorityChannelSettings);
    }

    private void createMaxPriorityNotificationChannel() {
        String maxPriorityChannelName = "Max Priority Channel";
        String maxPriorityChannelDescription = "Max Priority Channel Description";
        int maxPriorityChannelImportance = android.app.NotificationManager.IMPORTANCE_MAX;
        boolean maxPriorityChannelEnableVibration = true;

//        Uri maxPriorityChannelSettingsSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
//
//        AudioAttributes maxPriorityChannelSettingsAudioAttributes = new AudioAttributes.Builder()
//                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
//                .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
//                .build();

        NotificationChannelSettings maxPriorityChannelSettings = new NotificationChannelSettings(
                MAX_PRIORITY_CHANNEL_ID, maxPriorityChannelName, maxPriorityChannelDescription,
                maxPriorityChannelImportance, maxPriorityChannelEnableVibration,
                null, null
        );

        createNotificationChannel(maxPriorityChannelSettings);
    }

    public Notification createInCallNotification(String channelId, String from) {
        Intent notificationClickIntent = new Intent(context, MainActivity.class);
        notificationClickIntent.setFlags(
                Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);

        PendingIntent pendingIntent = PendingIntent.getActivity(
                context,
                40,
                notificationClickIntent,
                PendingIntent.FLAG_IMMUTABLE);

        Intent hangupButtonIntent = new Intent(context, NotificationActionReceiver.class);
        hangupButtonIntent.setAction(CallEvents.HANGUP_CALL.name());

        PendingIntent hangupPendingIntent = PendingIntent.getBroadcast(
                context,
                50,
                hangupButtonIntent,
                PendingIntent.FLAG_IMMUTABLE);

        Person caller = new Person.Builder()
                .setName(from)
                .setImportant(true)
                .build();

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
                .setSmallIcon(android.R.drawable.sym_call_outgoing)
                .setOngoing(true)
                .setUsesChronometer(true)
                .setContentIntent(pendingIntent);

        builder.setStyle(NotificationCompat.CallStyle.forOngoingCall(
                caller,
                hangupPendingIntent
        ));

        return builder.build();
    }

    public Notification createIncomingCallNotification(String channelId, String name, int priority) {
        Intent acceptCallIntent = new Intent(context, MainActivity.class);
        acceptCallIntent.setAction(CallEvents.INCOMING_CALL_ACCEPT.name());
        acceptCallIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);

        PendingIntent acceptPendingIntent = PendingIntent.getActivity(
                context,
                10,
                acceptCallIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Intent declineCallIntent = new Intent(context, NotificationActionReceiver.class);
        declineCallIntent.setAction(CallEvents.INCOMING_CALL_DECLINE.name());

        PendingIntent rejectPendingIntent = PendingIntent.getBroadcast(
                context,
                20,
                declineCallIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Person incomingCaller = new Person.Builder()
                .setName(name)
                .setImportant(true)
                .build();

        Intent fullScreenIntent = new Intent(context, MainActivity.class);
        PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(
                context,
                30,
                fullScreenIntent,
                PendingIntent.FLAG_IMMUTABLE);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setPriority(priority)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setOngoing(true)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setStyle(NotificationCompat.CallStyle.forIncomingCall(
                        incomingCaller,
                        rejectPendingIntent,
                        acceptPendingIntent));

        return builder.build();
    }

    public void cancelCallNotification() {
        notificationManager.cancel(NotificationHelper.CALL_NOTIFICATION_ID);
    }
}
