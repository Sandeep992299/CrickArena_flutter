import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void showOfflineBanner() {
  showSimpleNotification(
    const Text(
      "Connection Lost",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: const Text("Don't worry, data is loaded from local storage."),
    background: Colors.orangeAccent,
    duration: const Duration(seconds: 5),
  );
}

void showOnlineBanner() {
  showSimpleNotification(
    const Text("Back Online!"),
    background: Colors.green,
    duration: const Duration(seconds: 3),
  );
}
