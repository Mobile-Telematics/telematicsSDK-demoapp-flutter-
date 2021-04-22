class Tag {
  final String source;
  final String tag;

  const Tag({
    required this.source,
    required this.tag,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as String;
    final tag = json['tag'] as String;

    return Tag(
      source: source,
      tag: tag,
    );
  }
}
