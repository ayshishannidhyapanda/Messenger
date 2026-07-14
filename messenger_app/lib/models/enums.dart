/// Mirrors `com.messenger.enumerated.MessageType`
enum MessageType {
  TEXT,
  FILE;

  static MessageType fromString(String value) =>
      MessageType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => MessageType.TEXT,
      );
}

/// Mirrors `com.messenger.enumerated.MediaType`
enum MediaType {
  VIDEO,
  AUDIO,
  IMG;

  static MediaType? fromString(String? value) {
    if (value == null) return null;
    return MediaType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MediaType.IMG,
    );
  }
}

/// Mirrors `com.messenger.enumerated.Reactions`
enum Reactions {
  HAPPY,
  SAD;

  static Reactions? fromString(String? value) {
    if (value == null) return null;
    return Reactions.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Reactions.HAPPY,
    );
  }
}
