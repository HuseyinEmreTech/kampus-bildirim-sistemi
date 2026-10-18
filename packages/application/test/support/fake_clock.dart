import 'package:campus_domain/campus_domain.dart';

final class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  set time(DateTime value) => _now = value;
}
