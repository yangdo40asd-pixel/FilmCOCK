import 'package:filmcock_app/core/time/app_clock.dart';

class FixedClock implements AppClock {
  final DateTime value;
  const FixedClock(this.value);
  @override
  DateTime now() => value;
}
