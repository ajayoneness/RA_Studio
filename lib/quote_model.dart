class Quote {
  final int id;
  final String color;
  final String quote;
  final int category;

  Quote({
    required this.id,
    required this.color,
    required this.quote,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      color: json['color'],
      quote: json['quote'],
      category: json['category'],
    );
  }
}
