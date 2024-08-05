import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';

class CarDetailsView extends StatefulWidget {
  final CarModel car;
  final bool isfavourite;

  const CarDetailsView({
    super.key,
    required this.car,
    required this.isfavourite,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CarDetailsViewState createState() => _CarDetailsViewState();
}

class _CarDetailsViewState extends State<CarDetailsView> {
  late bool isFavourite;
  late CarModel car;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.isfavourite;
    car = widget.car;
  }

  Future<void> addToFavorites(CarModel car) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'favourite': FieldValue.arrayUnion([car.toJson()]),
      });
      setState(() {
        isFavourite = true;
      });
      Logger().i('Car "${car.carName}" added to favorites.');
    } catch (e) {
      Logger().e('Error adding car to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(CarModel car) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'favourite': FieldValue.arrayRemove([car.toJson()]),
      });
      setState(() {
        isFavourite = false;
      });
      Logger().i('Car "${car.carName}" removed from favorites.');
    } catch (e) {
      Logger().e('Error removing car from favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double carouselWidth = deviceWidth * 0.9;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/55.jpg'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: carouselWidth,
                    child: CarouselSlider.builder(
                      itemCount: car.photos.length,
                      itemBuilder: (context, index, realIdx) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image(
                                  image: car.photos.isNotEmpty &&
                                          car.photos[index].isNotEmpty
                                      ? NetworkImage(car.photos[
                                          index]) // Use network image if URL is not empty
                                      : const AssetImage('assets/150.png')
                                          as ImageProvider, // Use default image if URL is empty or null
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // If network image fails to load, show default image
                                    return Image.asset(
                                      'assets/default_image.png', // Path to your default image asset
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0, // Adjusted for the custom width
                        autoPlay: false,
                        enlargeCenterPage: true,
                        aspectRatio: 1.0,
                        enableInfiniteScroll: false, // Disable infinite scroll
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            Icons.directions_car, 'Car Name', car.carName),
                        _buildInfoRow(Icons.addchart_sharp, 'Model', car.model),
                        _buildInfoRow(
                            Icons.attach_money, 'Price', 'Rs. ${car.price}'),
                        _buildInfoRow(
                            Icons.speed, 'Mileage', '${car.mileage} km'),
                        _buildInfoRow(
                            Icons.calendar_today, 'Year', car.year.toString()),
                        _buildInfoRow(
                            Icons.check_circle, 'Condition', car.condition),
                        _buildInfoRow(
                            Icons.location_on, 'Location', car.location),
                        _buildInfoRow(
                            Icons.phone, 'Phone number', '${car.tpnumber}'),
                        const SizedBox(height: 10),
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (isFavourite) {
                                    await removeFromFavorites(widget.car);
                                  } else {
                                    await addToFavorites(widget.car);
                                  }
                                },
                                icon: Icon(
                                  isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: const Color.fromARGB(255, 190, 24, 38),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () {
                                  // Handle add to cart action
                                },
                                icon: const Icon(Icons.shopping_cart),
                                color: const Color.fromARGB(255, 207, 23, 60),
                                iconSize: 32,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 12, 12, 12), size: 25),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(223, 77, 72, 72),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 5, 5, 5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
