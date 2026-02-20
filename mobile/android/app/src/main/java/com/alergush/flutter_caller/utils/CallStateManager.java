package com.alergush.flutter_caller.utils;

import com.twilio.voice.Call;
import com.twilio.voice.CallInvite;

import java.util.HashMap;
import java.util.Map;

public class CallStateManager {
    private static CallStateManager instance;

    private volatile Call activeCall;
    private volatile CallInvite activeCallInvite;

    private volatile CallStatus callStatus = CallStatus.IDLE;
    private volatile String callError = null;
    private volatile String callerName = null;
    private volatile String callerPhone = null;
    private volatile boolean isMuted = false;
    private volatile boolean isSpeakerOn = false;
    private volatile long callStartTime = 0;

    private volatile boolean isRegistered = false;
    private volatile String registrationError = null;
    private volatile boolean isFirstConnection = false;
    private boolean isLocallyDisconnected = false;

    private CallStateManager() {
    }

    public static synchronized CallStateManager getInstance() {
        if (instance == null) {
            instance = new CallStateManager();
        }

        return instance;
    }

    public synchronized void setCallStatus(CallStatus callStatus, String callError) {
        this.callStatus = callStatus;
        this.callError = callError;

        if (callStatus == CallStatus.IDLE || callStatus == CallStatus.DISCONNECTED) {
            this.isMuted = false;
            this.isSpeakerOn = false;
        }
    }


    public void setLocallyDisconnected(boolean locallyDisconnected) {
        this.isLocallyDisconnected = locallyDisconnected;
    }

    public synchronized boolean isLocallyDisconnected() {
        return isLocallyDisconnected;
    }

    public synchronized void setCallerName(String callerName) {
        this.callerName = callerName;
    }

    public synchronized void setCallerPhone(String callerPhone) {
        this.callerPhone = callerPhone;
    }

    public synchronized void setCallStartTime(long callStartTime) {
        this.callStartTime = callStartTime;
    }

    public long getCallStartTime() {
        return callStartTime;
    }

    public String getCallError() {
        return callError;
    }

    public synchronized void setMute(boolean muted) {
        this.isMuted = muted;
    }

    public synchronized void setSpeaker(boolean speaker) {
        this.isSpeakerOn = speaker;
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();

        map.put("isRegistered", isRegistered);
        map.put("registrationError", registrationError);
        map.put("callStatus", callStatus.name());
        map.put("callError", callError);
        map.put("callerName", callerName);
        map.put("callerPhone", callerPhone);
        map.put("isMuted", isMuted);
        map.put("isSpeakerOn", isSpeakerOn);
        map.put("callStartTime", callStartTime);
        map.put("isFirstConnection", isFirstConnection);

        return map;
    }

    public CallStatus getCallStatus() {
        return callStatus;
    }

    public synchronized void setActiveCall(Call call) {
        this.activeCall = call;
    }

    public synchronized void setActiveCallInvite(CallInvite invite) {
        this.activeCallInvite = invite;
    }

    public synchronized void setRegistrationStatus(boolean success, String error) {
        this.isRegistered = success;
        this.registrationError = error;
    }

    public Call getActiveCall() {
        return activeCall;
    }

    public CallInvite getActiveCallInvite() {
        return activeCallInvite;
    }

    public  String getCallerName() {
        return callerName;
    }

    public  String getCallerPhone() {
        return callerPhone;
    }

    public synchronized void setIsFirstConnection(boolean isFirstConnection) {
        this.isFirstConnection = isFirstConnection;
    }

    public boolean getIsFirstConnection() {
        return isFirstConnection;
    }

    public synchronized void reset() {
        this.activeCall = null;
        this.activeCallInvite = null;
        this.callStatus = CallStatus.IDLE;
        this.callError = null;
        this.callerName = null;
        this.callerPhone = null;
        this.isMuted = false;
        this.isSpeakerOn = false;
        this.callStartTime = 0;
        this.isFirstConnection = false;
        this.isLocallyDisconnected = false;
    }
}
