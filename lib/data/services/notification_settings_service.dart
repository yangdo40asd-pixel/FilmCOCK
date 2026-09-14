import 'package:flutter/foundation.dart';

class NotificationSettingsService {
  NotificationSettingsService._();

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void notifyChanged() {
    revision.value++;
  }
}
