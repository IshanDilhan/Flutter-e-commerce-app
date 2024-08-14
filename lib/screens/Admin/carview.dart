import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/providers/user_cars_provider.dart';
import 'package:myapp/screens/Admin/add_item.dart';
import 'package:myapp/screens/Admin/edit_cardata.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:provider/provider.dart';

class ViewCarsPage extends StatefulWidget {
  const ViewCarsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewCarsPageState createState() => _ViewCarsPageState();
}

class _ViewCarsPageState extends State<ViewCarsPage> {
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

  Future<void> deleteCar(BuildContext context, String carId) async {
    final Logger logger = Logger();

    try {
      // Fetch the document to get the image URLs
      final DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('cars').doc(carId).get();

      if (docSnapshot.exists) {
        final List<String> photoUrls = List<String>.from(docSnapshot['photos']);

        // Delete each image from Firebase Storage
        for (String url in photoUrls) {
          await FirebaseStorage.instance.refFromURL(url).delete();
          logger.i('Deleted image from URL: $url');
        }

        // Delete the Firestore document
        await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
        logger.i('Deleted car document with ID: $carId');

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car and images deleted successfully')),
        );

        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        logger.e('Document with ID: $carId does not exist.');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Document does not exist')),
        );
      }
    } catch (e) {
      logger.e('Error deleting car: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Cars'),
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

          return Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddItemPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 116, 221),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add,
                          color: Colors.white), // Add your desired icon here
                      SizedBox(width: 8), // Add spacing between icon and text
                      Text(
                        'Add Car',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: car.photos.length,
                              itemBuilder: (context, photoIndex) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      car.photos[photoIndex],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.grey.shade300, width: 1)),
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoBox('Car Name', car.carName),
                                _buildInfoBox('Model', car.model),
                                _buildInfoBox('Year', car.year.toString()),
                                _buildInfoBox('Price', '\$${car.price}'),
                                _buildInfoBox('Mileage', '${car.mileage} km'),
                                _buildInfoBox('Condition', car.condition),
                                _buildInfoBox(
                                    'Phone number', '${car.tpnumber}'),
                                _buildInfoBox('Location', car.location),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Description:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepPurple)),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(car.description,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black87)),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateCarPage(car: car),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await deleteCar(context, car.id);
                                        carProvider.fetchCars();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 100.0, right: 16.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.home),
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple)),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
