extension TimeFormatting on int {
  /// Formats the integer (representing seconds) to a MM:SS string.
  String toMMSS() {
    final int minutes = this ~/ 60;
    final int seconds = this % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
