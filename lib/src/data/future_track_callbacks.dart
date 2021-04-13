import 'package:telematics_sdk/src/data/status.dart';
import 'package:telematics_sdk/src/data/tag.dart';

typedef OnTagAddCallback = void Function(
  Status status,
  Tag tag,
  int activationTime,
);

typedef OnTagRemoveCallback = void Function(
  Status status,
  Tag tag,
  int deactivationTime,
);

typedef OnAllTagsRemoveCallback = void Function(
  Status status,
  int deactivatedTagsCount,
  int time,
);

typedef OnGetTagsCallback = void Function(
  Status status,
  List<Tag>? tags,
  int time,
);
