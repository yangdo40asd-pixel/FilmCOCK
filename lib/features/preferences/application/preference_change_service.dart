import 'package:flutter/foundation.dart';

class PreferenceChangeService {
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void notifyChanged() {
    revision.value++;
  }
}
