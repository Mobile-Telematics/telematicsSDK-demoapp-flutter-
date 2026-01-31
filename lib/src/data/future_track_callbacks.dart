import 'package:telematics_sdk/src/data/models/status.dart';
import 'package:telematics_sdk/src/data/models/tag.dart';

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
  int time,
);

typedef OnGetTagsCallback = void Function(
  Status status,
  List<Tag>? tags,
  int time,
);
