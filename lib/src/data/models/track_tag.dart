import 'package:flutter/foundation.dart';

@immutable
class TrackTag {
  final String? source;
  final String tag;
  final String? type;

  const TrackTag({
    required this.source,
    required this.tag,
    required this.type,
  });

  factory TrackTag.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as String?;
    final tag = json['tag'] as String;
    final type = json['type'] as String?;

    return TrackTag(
      source: source,
      tag: tag,
      type: type,
    );
  }

  Map<String, Object> toJson() => {
        if (source != null) 'source': source!,
        'tag': tag,
        if (type != null) 'type': type!,
      };
}
