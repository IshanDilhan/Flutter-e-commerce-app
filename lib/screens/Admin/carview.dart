import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';
import 'package:myapp/screens/main_screen.dart';

class ViewCarsPage extends StatelessWidget {
  const ViewCarsPage({super.key});

  Future<List<CarModel>> fetchCars() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('cars').get();
    return snapshot.docs
        .map((doc) => CarModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Document does not exist')),
        );
      }
    } catch (e) {
      logger.e('Error deleting car: $e');
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
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<CarModel>>(
        future: fetchCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cars available'));
          }

          final cars = snapshot.data!;

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Card(
                margin: const EdgeInsets.all(10),
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
                            child: Image.network(car.photos[photoIndex]),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Car Name: ${car.carName}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Model: ${car.model}'),
                          Text('Year: ${car.year}'),
                          Text('Price: \$${car.price}'),
                          Text('Mileage: ${car.mileage} km'),
                          Text('Condition: ${car.condition}'),
                          Text('Phone number: ${car.tpnumber}'),
                          Text('Location: ${car.location}'),
                          Text('Description: ${car.description}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await deleteCar(context, car.id);
                                  // Update UI after deletion
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Car deleted')),
                                  );
                                  // Refresh the page
                                  (context as Element).reassemble();
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
          );
        },
      ),
    );
  }
}

class UpdateCarPage extends StatelessWidget {
  final CarModel car;

  const UpdateCarPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Car'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text(
            'Update form for ${car.carName}'), // Replace this with the actual update form
      ),
    );
  }
}
