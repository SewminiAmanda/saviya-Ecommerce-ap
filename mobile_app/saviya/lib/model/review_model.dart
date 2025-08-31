// model/review_model.dart
class Review {
  final int id;
  final int rating;
  final String comment;
  final int productId;
  final int userId;
  final String createdAt;
  final String userFirstName;
  final String userLastName;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.productId,
    required this.userId,
    required this.createdAt,
    required this.userFirstName,
    required this.userLastName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'] ,
      productId: json['productId'], 
      userId: json['userId'],
      createdAt: json['createdAt'],
      userFirstName: json['userFirstName'] ,
      userLastName: json['userLastName'] ,
    );
  }
}
