class CarModel {
  String id;
  String userId;
  String carName;
  String model;
  int year;
  double price;
  int mileage;
  String condition;
  String description;
  String location;
  List<String> photos;

  CarModel({
    required this.id,
    required this.userId,
    required this.carName,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.condition,
    required this.description,
    required this.location,
    required this.photos,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      userId: json['userId'],
      carName: json['carName'],
      model: json['model'],
      year: json['year'],
      price: (json['price'] as num).toDouble(),
      mileage: json['mileage'],
      condition: json['condition'],
      description: json['description'],
      location: json['location'],
      photos: List<String>.from(json['photos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'carName': carName,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'condition': condition,
      'description': description,
      'location': location,
      'photos': photos,
    };
  }
}
