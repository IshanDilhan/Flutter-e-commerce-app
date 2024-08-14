import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/car_model.dart';
import 'package:myapp/providers/car_list_provider.dart';
import 'package:provider/provider.dart';

class CarDetailsView extends StatefulWidget {
  final CarModel car;
  final bool isfavourite;
  final bool iscart;

  const CarDetailsView({
    super.key,
    required this.car,
    required this.isfavourite,
    required this.iscart,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CarDetailsViewState createState() => _CarDetailsViewState();
}

class _CarDetailsViewState extends State<CarDetailsView> {
  late bool isFavourite;
  late bool iscart;
  late CarModel car;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.isfavourite;
    iscart = widget.iscart;
    car = widget.car;
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
                            Icons.phone,
                            'registered date',
                            DateFormat.yMMMMd()
                                .format(car.registrationDateTime)),
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
                        Consumer<CarListProvider>(
                            builder: (context, carListProvider, child) {
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if (isFavourite) {
                                      await carListProvider
                                          .removeFromFavorites(car);
                                      setState(() {
                                        isFavourite = false;
                                      });
                                    } else {
                                      await carListProvider.addToFavorites(car);
                                      setState(() {
                                        isFavourite = true;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        const Color.fromARGB(255, 190, 24, 38),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () async {
                                    if (iscart) {
                                      await carListProvider.removeFromCart(car);
                                      setState(() {
                                        iscart = false;
                                      });
                                    } else {
                                      await carListProvider.addToCart(car);
                                      setState(() {
                                        iscart = true;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    iscart
                                        ? Icons.shopping_cart_rounded
                                        : Icons.shopping_cart_outlined,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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
                fontSize: 2,
                color: Color.fromARGB(255, 5, 5, 5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
