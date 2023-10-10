class AppConstants {
  static const String appName = 'Dellenhauer';
  static const String firebaseUrl = 'https://fcm.googleapis.com/fcm/send';
  static const String authorizationHeaderFCMDev =
      'key=AAAAqZ6nvZU:APA91bENicL_JbGD1EmS63KGgY5vf6yardkgkc9DF7Hq82A-2dd1vo71UG9vlUmEQTps34tHyfl8tHJKgDPNa39YBz3b89Yt4CnDUnrCyhobqtGup72OQkNkuwxXDf1yR4M7PyS7L4Uz';
  static const String authorizationHeaderFCMPro =
      'key=AAAAqZ6nvZU:APA91bENicL_JbGD1EmS63KGgY5vf6yardkgkc9DF7Hq82A-2dd1vo71UG9vlUmEQTps34tHyfl8tHJKgDPNa39YBz3b89Yt4CnDUnrCyhobqtGup72OQkNkuwxXDf1yR4M7PyS7L4Uz';
  static const String dellenhauereBestCMSKey =
      'WPAObiq6mx57kW9kpZFhOERymRu3SHin';

  static const String cloudFunctionDevAcceptPendingUser =
      'https://us-central1-dellenhauerdev.cloudfunctions.net/sendActivationPushNotification';

  static const String cloudFunctionProAcceptPendingUser =
      'https://us-central1-dellenhauer-eae5f.cloudfunctions.net/sendActivationPushNotification';

  static const String cloudFunctionDevDeleteChannelFromDatabase =
      'https://us-central1-dellenhauerdev.cloudfunctions.net/deleteChannelAndReferences';
  static const String cloudFunctionProDeleteChannelFromDatabase =
      'https://us-central1-dellenhauer-ease5f.cloudfunctions.net/deleteChannelAndReferences';

  static const String X_API_KEY = "WPAObiq6mx57kW9kpZFhOERymRu3SHin";
}
