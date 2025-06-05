import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;

  final List<String> _offers = [
    "🏏 20% OFF on all cricket gear!",
    "🔥 Buy 1 Get 1 Free on bats!",
    "🚚 Free shipping on orders over \$50!",
    "🎉 Flash Sale! 30% off today!",
    "👑 VIP Offer just for CrickArena users!",
  ];

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Create channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'offer_channel',
      'Offers',
      description: 'Channel for cricket offers notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _startSendingOffers();
  }

  void _startSendingOffers() {
    final random = Random();

    // Show first notification immediately
    _showRandomOffer(random);

    // Then every 1 minutes
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _showRandomOffer(random);
    });
  }

  Future<void> _showRandomOffer(Random random) async {
    final offer = _offers[random.nextInt(_offers.length)];

    await flutterLocalNotificationsPlugin.show(
      0,
      "CrickArena Special Offer",
      offer,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'offer_channel',
          'Offers',
          channelDescription: 'Channel for cricket offers',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}
