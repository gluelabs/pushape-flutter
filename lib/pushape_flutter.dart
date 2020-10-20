import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class Pushape {
  static Pushape _instance;
  static get instance {
    return _instance ?? Pushape();
  }

  Pushape() {
    if (_instance != null) return;
    _instance = this;
  }

  //pushId
  String _pushId;
  String get pushId => _pushId;

  //callbacks closures
  Function(Map<String, dynamic>) _onMessageCallback;
  Function(Map<String, dynamic>) _onResumeCallback;
  Function(Map<String, dynamic>) _onLaunchCallback;

  //firebase messaging object
  FirebaseMessaging _fcm;
  String _fcmToken = '';

  Future<bool> register({
    @required int pushapeAppId,
    String userInternalId,
    Function(Map<String, dynamic>) onMessage,
    Function(Map<String, dynamic>) onResume,
    Function(Map<String, dynamic>) onLaunch,
  }) async {
    this._fcm = FirebaseMessaging();

    DeviceInfoPlugin di = DeviceInfoPlugin();
    String udid = '';
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await di.iosInfo;
      udid = iosInfo.identifierForVendor;

      this._fcm.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
      this._fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    } else {
      AndroidDeviceInfo androidInfo = await di.androidInfo;
      udid = androidInfo.androidId;
    }

    this._fcm.configure(
          onMessage: (Map<String, dynamic> msg) async => _onMessageCallback(msg),
          onResume: (Map<String, dynamic> msg) async => _onResumeCallback(msg),
          onLaunch: (Map<String, dynamic> msg) async => _onLaunchCallback(msg),
        );

    // setup callback funcs
    if (onMessage == null) {
      _onMessageCallback = (Map<String, dynamic> msg) => print(msg);
    } else {
      _onMessageCallback = onMessage;
    }
    if (onResume == null) {
      _onResumeCallback = (Map<String, dynamic> msg) => print(msg);
    } else {
      _onResumeCallback = onResume;
    }
    if (onLaunch == null) {
      _onLaunchCallback = (Map<String, dynamic> msg) => print(msg);
    } else {
      _onLaunchCallback = onLaunch;
    }

    this._fcmToken = await this._fcm.getToken();

    //register to pushape
    print('[PUSHAPE] Registering to Pushape with app id: $pushapeAppId');
    final url = 'https://gluepushape.appspot.com';
    Map<String, dynamic> body = {
      "id_app": pushapeAppId,
      "platform": "chrome",
      "uuid": udid,
      "regid": this._fcmToken,
    };

    // set internal id
    if (userInternalId != null) {
      print('[PUSHAPE] Registering internal id: $userInternalId');
      body['internal_id'] = userInternalId;
    }

    // send post request for registering
    Map<String, String> headers = {
      "Accept": 'application/json',
      "Content-Type": 'application/json',
    };
    final encodedBody = jsonEncode(body);
    http.Response res;
    try {
      res = await http.post(
        '$url/subscribe',
        headers: headers,
        body: encodedBody,
      );
    } catch (e) {
      print('[PUSHAPE] Unable to regiter');
      print(e);
    }

    if (res != null && res.statusCode == 201) {
      try {
        final decodedBody = json.decode(res.body);
        this._pushId = decodedBody['push_id'];
        print('[PUSHAPE] Successfully registered, push id: ${this.pushId}');
        return true;
      } catch (e) {
        print('[PUSHAPE] Unable to regiter');
        print(e);
      }
    }

    return false;
  }

  void setOnMessageCallback(Function(Map<String, dynamic>) callback) {
    this._onMessageCallback = callback;
    print('[PUSHAPE] Configured callback for "onMessage" event');
  }

  void setOnLaunchCallback(Function(Map<String, dynamic>) callback) {
    this._onLaunchCallback = callback;
    print('[PUSHAPE] Configured callback for "onLaunch" event');
  }

  void setOnResumeCallback(Function(Map<String, dynamic>) callback) {
    this._onResumeCallback = callback;
    print('[PUSHAPE] Configured callback for "onResume" event');
  }
}