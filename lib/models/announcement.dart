class Announcement {
  final String title;
  final String content;
  final DateTime date;
  final String? authorName;

  Announcement({
    required this.title,
    required this.content,
    required this.date,
    this.authorName,
  });
}
