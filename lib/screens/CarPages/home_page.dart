import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/providers/car_list_provider.dart';
import 'package:myapp/providers/user_cars_provider.dart';
import 'package:myapp/screens/CarPages/car_details_page.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/profile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _isSearchVisible = false;

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
        backgroundColor: const Color.fromARGB(255, 107, 123, 202),
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Align(
            //   alignment: Alignment.center,
            //   child: Text(
            //     '  Ride Time Car Sale',
            //     style: TextStyle(
            //       fontSize: 22,
            //       fontFamily: 'Calistoga-Regular',
            //       fontWeight: FontWeight.w700,
            //       color: Color.fromARGB(255, 179, 182, 205),
            //       letterSpacing:
            //           1.2, // Adds spacing between letters for a more polished look
            //       shadows: [
            //         Shadow(
            //           blurRadius: 4.0,
            //           color: const Color.fromARGB(255, 81, 107, 91)
            //               .withOpacity(0.5),
            //           offset: const Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //     height: 4), // Spacing between company name and welcome message
            Consumer<UserInfoProvider>(
              builder: (context, userInfoProvider, child) {
                final username = userInfoProvider.userInfo["username"];
                return Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Text(
                        username == null
                            ? 'Welcome to the App'
                            : 'Welcome, $username!',
                        style: const TextStyle(
                          fontFamily: 'BebasNeue-Regular',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 33, 35, 37),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery =
                      ''; // Clear search query when hiding search bar
                }
              });
            },
          ),
        ],
        bottom: _isSearchVisible
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by car name...',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 248, 248, 250),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Consumer2<CarProvider, CarListProvider>(
        // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
        builder: (context, carProvider, CarListProvider, child) {
          if (carProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (carProvider.cars.isEmpty) {
            return const Center(
                child: Text('No cars available',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
          }

          final cars = carProvider.cars
              .where((car) => car.carName.toLowerCase().contains(_searchQuery))
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Carousel Slider
                CarouselSlider(
                  options: CarouselOptions(
                    height: 140.0, // Reduced height
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 1,
                    viewportFraction: 0.8,
                    enableInfiniteScroll: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                  ),
                  items: cars.map((car) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            CarListProvider.isFavorite(car.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetailsView(
                                    car: car,
                                    isfavourite:
                                        CarListProvider.isFavorite(car.id),
                                    iscart: CarListProvider.isCart(car.id)),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  car.photos.isNotEmpty
                                      ? car.photos[0]
                                      : 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black54,
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          car.carName,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 238, 231, 231),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '\$${car.price}',
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 4, 90, 227),
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
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
                // Grid of Car Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 3 / 1, // Adjusted aspect ratio
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetailsView(
                                  car: car,
                                  isfavourite:
                                      CarListProvider.isFavorite(car.id),
                                  iscart: CarListProvider.isCart(car.id),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 9,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8), // Increased corner radius
                                  child: Image.network(
                                    car.photos.isNotEmpty
                                        ? car.photos[0]
                                        : 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    width: 120, // Increased width
                                    height: 120, // Increased height
                                  ),
                                ),
                                const SizedBox(width: 16), // Increased spacing
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        car.carName,
                                        style: const TextStyle(
                                          fontSize: 20, // Adjusted font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                          height:
                                              8), // Spacing between elements
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '\$${car.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize:
                                                  18, // Adjusted font size
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 31, 107, 169),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                              width: 8), // Adjusted spacing
                                          const Icon(
                                            Icons.location_on,
                                            color:
                                                Color.fromARGB(255, 77, 79, 80),
                                          ),
                                          const SizedBox(
                                              width:
                                                  4), // Spacing between icon and text
                                          Expanded(
                                            child: Text(
                                              car.location,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 47, 51, 57),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: 8), // Spacing between rows
                                      Row(
                                        children: [
                                          Text(
                                            '${car.mileage} Km',
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                              width: 8), // Adjusted spacing
                                          Text(
                                            'Condition: ${car.condition}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        CarListProvider.isCart(car.id)
                                            ? Icons.shopping_cart_rounded
                                            : Icons.shopping_cart_outlined,
                                        color: Colors.green,
                                        size: 29,
                                      ),
                                      onPressed: () async {
                                        await (CarListProvider.isCart(car.id)
                                            ? CarListProvider.removeFromCart(
                                                car)
                                            : CarListProvider.addToCart(car));
                                        Logger().i(
                                            CarListProvider.isCart(car.id)
                                                ? 'Removed from carts'
                                                : 'Marked as carts');
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        CarListProvider.isFavorite(car.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await (CarListProvider.isFavorite(
                                                car.id)
                                            ? CarListProvider
                                                .removeFromFavorites(car)
                                            : CarListProvider.addToFavorites(
                                                car));
                                        Logger().i(
                                            CarListProvider.isFavorite(car.id)
                                                ? 'Removed from favorites'
                                                : 'Marked as favorite');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            fetchInitialCars();
            context.read<CarListProvider>().fetchFavoriteCarIds();
            context.read<CarListProvider>().fetchCartCarIds();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
