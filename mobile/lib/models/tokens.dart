class OperatorCredentials {
  final String twilioAccessToken;
  final String fcmToken;
  final String operatorId;

  const OperatorCredentials({
    required this.twilioAccessToken,
    required this.fcmToken,
    required this.operatorId,
  });
}
