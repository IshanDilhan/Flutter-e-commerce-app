import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';
import 'package:myapp/providers/car_list_provider.dart';
import 'package:myapp/providers/payment_provider.dart';
import 'package:myapp/screens/CarPages/car_details_page.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  List<CarModel> cartItems = [];
  Future<void>? _fetchCartItemsFuture;

  double totalPrice = 0.0;
  @override
  void initState() {
    super.initState();
    _fetchCartItemsFuture = fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user?.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        Logger().i('Raw Firestore Data: $data');

        // Ensure 'cartItems' is a list
        if (data != null && data.containsKey('cartItems')) {
          final cartList = data['cartItems'] as List<dynamic>;
          Logger().i('Raw Cart Items List: $cartList');

          // Convert the cart list to CarModel objects
          cartItems = cartList.map((carData) {
            return CarModel.fromJson(carData as Map<String, dynamic>);
          }).toList();

          Logger().i('Parsed Cart Items: $cartItems');
          double newTotalPrice = 0.0;

          for (int i = 0; i < cartItems.length; i++) {
            newTotalPrice += cartItems[i].price;
            // Log each step to track how the total price is computed
            Logger().i(
                'Item $i price: ${cartItems[i].price}, newTotalPrice: $newTotalPrice');
          }
          setState(() {
            totalPrice = newTotalPrice;
          });
        } else {
          Logger().i('No cartItems field found or it is empty.');
          cartItems = [];
        }
      } else {
        Logger().i('User document does not exist.');
        cartItems = [];
      }
    } catch (e) {
      Logger().i('Error fetching cart items: $e');
      cartItems = [];
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total price

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 107, 123, 202),
        elevation: 0,
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Your Carts',
                style: TextStyle(
                  fontFamily: 'BebasNeue-Regular',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 33, 35, 37),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/55.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: FutureBuilder<void>(
                  future: _fetchCartItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error fetching cart items',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else if (cartItems.isEmpty) {
                      return const Center(
                        child: Text(
                          'No items in cart',
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
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final car = cartItems[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CarDetailsView(
                                      car: car,
                                      isfavourite: context
                                          .read<CarListProvider>()
                                          .isFavorite(car.id),
                                      iscart: true,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                color: Color.fromARGB(
                                                    255, 77, 79, 80),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                '${car.mileage} Km',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Condition: ${car.condition}',
                                                style: const TextStyle(
                                                    fontSize: 14),
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
                                          'cartItems': FieldValue.arrayRemove(
                                              [car.toJson()])
                                        });
                                        setState(() {
                                          totalPrice = totalPrice - car.price;
                                          Provider.of<CarListProvider>(context,
                                                  listen: false)
                                              .removeFromCart(car);
                                          cartItems.removeAt(index);
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
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total Price: Rs. $totalPrice',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 31, 107, 169),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color.fromARGB(255, 31, 107, 169),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<PaymentProvider>(context, listen: false)
                          .getPayment((totalPrice * 100).toInt().toString(),
                              cartItems, context);
                    },
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
