import 'package:telematics_sdk/src/data/models/status.dart';
import 'package:telematics_sdk/src/data/models/tag.dart';

class FutureTrackTagAddResult {
  final Status status;
  final Tag tag;
  final int activationTime;

  const FutureTrackTagAddResult({
    required this.status,
    required this.tag,
    required this.activationTime,
  });
}

class FutureTrackTagRemoveResult {
  final Status status;
  final Tag tag;
  final int deactivationTime;

  const FutureTrackTagRemoveResult({
    required this.status,
    required this.tag,
    required this.deactivationTime,
  });
}

class FutureTrackTagsRemoveResult {
  final Status status;
  final int time;

  const FutureTrackTagsRemoveResult({required this.status, required this.time});
}

class FutureTrackTagsResult {
  final Status status;
  final List<Tag>? tags;
  final int time;

  const FutureTrackTagsResult({
    required this.status,
    required this.tags,
    required this.time,
  });
}
