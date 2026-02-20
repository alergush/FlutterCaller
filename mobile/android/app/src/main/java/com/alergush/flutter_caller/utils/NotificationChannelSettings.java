package com.alergush.flutter_caller.utils;

import android.media.AudioAttributes;
import android.net.Uri;

public class NotificationChannelSettings {
    public String id;
    public String name;
    public String description;
    public int importance;
    public boolean enableVibration;
    public Uri sound;
    public AudioAttributes audioAttributes;

    public  NotificationChannelSettings(String id, String name, String description, int importance,
                                        boolean enableVibration, Uri sound, AudioAttributes audioAttributes) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.importance = importance;
        this.enableVibration = enableVibration;
        this.sound = sound;
        this.audioAttributes = audioAttributes;
    }
}
