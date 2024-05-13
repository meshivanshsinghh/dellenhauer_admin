import 'package:firebase_core/firebase_core.dart';

enum Environment { production, development }

class AppConstants {
  static const Environment currentEnvironment = Environment.production;
  static const String appName = 'Dellenhauer';
  static const String firebaseUrl = 'https://fcm.googleapis.com/fcm/send';
  static const String dellenhauereBestCMSKey =
      'WPAObiq6mx57kW9kpZFhOERymRu3SHin';

  static String get getAuthorizationHeader {
    String authHeader;
    switch (currentEnvironment) {
      case Environment.production:
        authHeader =
            'key=AAAA7bW8uoY:APA91bHHpS8mnv2TBstuwPDCFlxSDeoSVGj_O9B82FbQ4BxvGv27xrmQ7ulVQtEi07Nzejd5FcrXlMNlzuIUu82rUyEX4_GVX8bIJTIEByCAl542IXc0aLxEddQmtaD_fba4mJMhL8Ae';
        break;
      case Environment.development:
        authHeader =
            'key=AAAAqZ6nvZU:APA91bENicL_JbGD1EmS63KGgY5vf6yardkgkc9DF7Hq82A-2dd1vo71UG9vlUmEQTps34tHyfl8tHJKgDPNa39YBz3b89Yt4CnDUnrCyhobqtGup72OQkNkuwxXDf1yR4M7PyS7L4Uz';
        break;
    }
    return authHeader;
  }

  static String get appBaseUrl {
    String appUrl;
    switch (currentEnvironment) {
      case Environment.production:
        appUrl = 'https://us-central1-dellenhauerprod.cloudfunctions.net';
        break;
      case Environment.development:
        appUrl = 'https://us-central1-dellenhauerdev.cloudfunctions.net';
        break;
    }
    return appUrl;
  }

  static String getAnalyticsData = '$appBaseUrl/getAnalyticsData';

  static String acceptPendingUser =
      '$appBaseUrl/sendActivationPushNotification';
  static String deleteChannelFromDatabase =
      '$appBaseUrl/deleteChannelAndReferences';
  static String deleteUser = '$appBaseUrl/deleteUserFromDellenhauer';

  static const String cmsWordpressUserCreate =
      'https://dellenhauer.com/wp-json/bestcms/v1/user/create';
  static const placeholderImage =
      'https://firebasestorage.googleapis.com/v0/b/dellenhauerprod.appspot.com/o/placeholder.png?alt=media&token=6c100cb7-db96-4477-a9d7-a06243800f1c';

  static FirebaseOptions get firebaseOptions {
    FirebaseOptions firebaseOptions;
    switch (currentEnvironment) {
      case Environment.development:
        firebaseOptions = const FirebaseOptions(
          apiKey: "AIzaSyAaRUuuIIbpBmVLds4AljLPNg5Vw3Eo4-E",
          authDomain: "dellenhauerdev.firebaseapp.com",
          projectId: "dellenhauerdev",
          storageBucket: "dellenhauerdev.appspot.com",
          messagingSenderId: "728511266197",
          appId: "1:728511266197:web:06b9aa9b37fefe3c0c8a9c",
          measurementId: "G-Q06DJ22R7S",
        );
        break;
      case Environment.production:
        firebaseOptions = const FirebaseOptions(
          apiKey: 'AIzaSyA_isyhzapY6H1d7gRxIN4BFojjhFsceac',
          appId: '1:1020956293766:web:442cffc177396de7e06f07',
          messagingSenderId: '1020956293766',
          projectId: 'dellenhauerprod',
          storageBucket: 'dellenhauerprod.appspot.com',
          measurementId: 'G-FCQ8X22P6N',
          authDomain: 'dellenhauerprod.firebaseapp.com',
        );
        break;
    }
    return firebaseOptions;
  }
}
