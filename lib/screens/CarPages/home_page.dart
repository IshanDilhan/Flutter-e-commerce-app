import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:myapp/screens/CarPages/car_details_page.dart';

import 'package:provider/provider.dart';
import 'package:myapp/providers/user_cars_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    fetchInitialCars();
  }

  void fetchInitialCars() {
    context.read<CarProvider>().fetchCars().catchError((error) {
      Logger().e('Error fetching cars: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          if (carProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (carProvider.cars.isEmpty) {
            return const Center(
                child: Text('No cars available',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
          }

          final cars = carProvider.cars;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: cars.map((car) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetailsView(car: car),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                            ),
                            child: Column(
                              children: [
                                Image.network(
                                  car.photos.isNotEmpty
                                      ? car.photos[0]
                                      : 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  height: 300,
                                  width: double.infinity,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${car.carName} - \$${car.price}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: cars.map((car) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailsView(car: car),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                car.photos.isNotEmpty
                                    ? car.photos[0]
                                    : 'https://via.placeholder.com/150',
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      car.carName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Price: \$${car.price}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Mileage: ${car.mileage} km',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
