import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';
import 'package:myapp/screens/CarPages/car_details_page.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  List<CarModel> favouriteCars = [];
  Future<void>? _fetchFavoritesFuture;
  @override
  void initState() {
    super.initState();
    _fetchFavoritesFuture = fetchFavoriteCars();
  }

  Future<void> fetchFavoriteCars() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        Logger().i('Raw Firestore Data: $data');

        // Ensure 'favourite' is a list
        if (data != null && data.containsKey('favourite')) {
          final favouriteList = data['favourite'] as List<dynamic>;
          Logger().i('Raw Favourite List: $favouriteList');

          // Convert the favourite list to CarModel objects
          favouriteCars = favouriteList.map((carData) {
            return CarModel.fromJson(carData as Map<String, dynamic>);
          }).toList();

          Logger().i('Parsed Favorite Cars: $favouriteCars');
        } else {
          Logger().i('No favourite field found or it is empty.');
          favouriteCars = [];
        }
      } else {
        Logger().i('User document does not exist.');
        favouriteCars = [];
      }
    } catch (e) {
      Logger().i('Error fetching favorite cars: $e');
      favouriteCars = [];
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 58, 123, 213),
                Color.fromARGB(255, 0, 210, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Implement notifications functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/55.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder<void>(
            future: _fetchFavoritesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error fetching favorite cars',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (favouriteCars.isEmpty) {
                return const Center(
                  child: Text(
                    'No favorite cars found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0), // Adjust the padding if needed
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 3 / 1,
                    ),
                    itemCount: favouriteCars.length,
                    itemBuilder: (context, index) {
                      final car = favouriteCars[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailsView(car: car, isfavourite: true),
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
                                borderRadius: BorderRadius.circular(8),
                                child: car.photos.isNotEmpty
                                    ? Image.network(
                                        car.photos[0],
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      )
                                    : Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 60,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      car.carName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Rs. ${car.price}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 31, 107, 169),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.location_on,
                                          color:
                                              Color.fromARGB(255, 77, 79, 80),
                                        ),
                                        const SizedBox(width: 4),
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
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '${car.mileage} Km',
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Condition: ${car.condition}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever),
                                color: Colors.red,
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('User')
                                      .doc(user?.uid)
                                      .update({
                                    'favourite':
                                        FieldValue.arrayRemove([car.toJson()])
                                  });
                                  setState(() {
                                    favouriteCars.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
