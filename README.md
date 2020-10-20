# pushape_flutter

A Flutter SDK for Pushape push notification handling

#### IMPORTANT
This package is heavily dependent from the [**firebase_messaging**](https://pub.dev/packages/firebase_messaging) package.\
Please, follow the [**installation guide**](https://pub.dev/packages/firebase_messaging) before install **pushape_flutter**

## Usage

Add `pushape_flutter` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages)

## Getting Started

Import the package
```
import 'package:pushape_flutter/pushape_flutter.dart';
```

Handle registration and callbacks

```
Pushape pushape = Pushape.instance; // get the pushape instance

await pushape.register(
  pushapeAppId: YOUR_APP_ID, // the app id: you can obtain it creating a new app on app.pushape.com
  userInternalId: 'your_custom_id', // you can put a username or user primary key
);

// set callback for OnMessage event
pushape.setOnMessageCallback((Map<String, dynamic> message) {
  print('on message $message');
});

// set callback for OnResume event
pushape.setOnResumeCallback((Map<String, dynamic> message) {
  print('on resume $message');
});

// set callback for OnLaunch event
pushape.setOnLaunchCallback((Map<String, dynamic> message) {
  print('on launch $message');
});
```


