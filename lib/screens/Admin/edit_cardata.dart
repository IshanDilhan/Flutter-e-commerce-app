import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/car_model.dart';

class UpdateCarPage extends StatelessWidget {
  final CarModel car;

  const UpdateCarPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    // TextEditingControllers to populate and retrieve data from text fields
    final TextEditingController carNameController =
        TextEditingController(text: car.carName);
    final TextEditingController modelController =
        TextEditingController(text: car.model);
    final TextEditingController yearController =
        TextEditingController(text: car.year.toString());
    final TextEditingController priceController =
        TextEditingController(text: car.price.toString());
    final TextEditingController mileageController =
        TextEditingController(text: car.mileage.toString());
    final TextEditingController conditionController =
        TextEditingController(text: car.condition);
    final TextEditingController tpnumberController =
        TextEditingController(text: car.tpnumber.toString());
    final TextEditingController locationController =
        TextEditingController(text: car.location);
    final TextEditingController descriptionController =
        TextEditingController(text: car.description);

    Future<void> updateCar() async {
      if (_formKey.currentState!.validate()) {
        await FirebaseFirestore.instance.collection('cars').doc(car.id).update({
          'carName': carNameController.text,
          'model': modelController.text,
          'year': int.parse(yearController.text),
          'price': double.parse(priceController.text),
          'mileage': int.parse(mileageController.text),
          'condition': conditionController.text,
          'tpnumber': int.parse(tpnumberController.text),
          'location': locationController.text,
          'description': descriptionController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car updated')),
        );
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Car'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: carNameController,
                decoration: const InputDecoration(labelText: 'Car Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the car name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the year';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: mileageController,
                decoration: const InputDecoration(labelText: 'Mileage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mileage';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: conditionController,
                decoration: const InputDecoration(labelText: 'Condition'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the condition';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tpnumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateCar,
                child: const Text('Update Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
