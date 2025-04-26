import 'dart:typed_data';

class HistoryItem {
  final DateTime date;
  final String fileName;
  final Uint8List image;
  final double probability;

  HistoryItem(
    this.date, {
    required this.fileName,
    required this.image,
    required this.probability,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fileName': fileName,
      'image': image,
      'probability': probability,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      DateTime.parse(json['date']),
      fileName: json['fileName'],
      image: Uint8List.fromList(json['image']),
      probability: json['probability'],
    );
  }
}

List<HistoryItem> mockedHistoryItems = [
  HistoryItem(
    DateTime.now(),
    fileName: "image1.jpg",
    image: Uint8List.fromList([0, 1, 2, 3]),
    probability: 0.95,
  ),
  HistoryItem(
    DateTime.now().subtract(const Duration(days: 1)),
    fileName: "image2.jpg",
    image: Uint8List.fromList([4, 5, 6, 7]),
    probability: 0.85,
  ),
];
