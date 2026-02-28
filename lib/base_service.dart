import 'package:get_it/get_it.dart';

import 'services/local_notification_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setup() async {
  if (!getIt.isRegistered<LocalNotificationService>()) {
    final notifications = LocalNotificationService();
    await notifications.initialize();
    getIt.registerSingleton<LocalNotificationService>(notifications);
  }
}
