import 'package:flutter/foundation.dart';

@immutable
class Status {
  static const Status success = Status._('SUCCESS');
  static const Status offline = Status._('OFFLINE');
  static const Status errorTagOperation = Status._('ERROR_TAG_OPERATION');
  static const Status errorInvalidTagSpecified =
      Status._('ERROR_INVALID_TAG_SPECIFIED');
  static const Status errorWrongTime = Status._('ERROR_WRONG_TIME');
  static const Status someError = Status._('SOME_ERROR');

  static const _values = {
    'SUCCESS': Status.success,
    'OFFLINE': Status.offline,
    'ERROR_TAG_OPERATION': Status.errorTagOperation,
    'ERROR_INVALID_TAG_SPECIFIED': Status.errorInvalidTagSpecified,
    'ERROR_WRONG_TIME': Status.errorWrongTime,
  };

  final String _value;

  const Status._(this._value);

  factory Status.fromString(String str) {
    return _values[str] ?? someError;
  }

  @override
  String toString() => _value;
}
