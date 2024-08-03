import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:myapp/models/car_model.dart';
import 'package:myapp/controllers/storage_controller.dart';
import 'package:myapp/screens/Admin/carview.dart'; // Update with your actual path

class UpdateCarPage extends StatefulWidget {
  final CarModel car;

  const UpdateCarPage({super.key, required this.car});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateCarPageState createState() => _UpdateCarPageState();
}

class _UpdateCarPageState extends State<UpdateCarPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController carNameController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController priceController;
  late TextEditingController mileageController;
  late TextEditingController conditionController;
  late TextEditingController tpnumberController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();
  // ignore: unused_field
  List<XFile>? _photos;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _imageUrls = List<String>.from(widget.car.photos);
    carNameController = TextEditingController(text: widget.car.carName);
    modelController = TextEditingController(text: widget.car.model);
    yearController = TextEditingController(text: widget.car.year.toString());
    priceController = TextEditingController(text: widget.car.price.toString());
    mileageController =
        TextEditingController(text: widget.car.mileage.toString());
    conditionController = TextEditingController(text: widget.car.condition);
    tpnumberController =
        TextEditingController(text: widget.car.tpnumber.toString());
    locationController = TextEditingController(text: widget.car.location);
    descriptionController = TextEditingController(text: widget.car.description);
  }

  Future<void> _pickImages() async {
    User? user = FirebaseAuth.instance.currentUser;
    _logger.i('Picking images...');
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 85);

    // ignore: unnecessary_null_comparison
    if (pickedFiles != null && pickedFiles.length <= 5) {
      _logger.i('Picked ${pickedFiles.length} images');

      for (XFile pickedFile in pickedFiles) {
        try {
          File file = File(pickedFile.path);

          // ignore: use_build_context_synchronously
          File? croppedImg = await cropImage(context, file);

          if (croppedImg != null) {
            _logger.i("Cropped correctly: ${croppedImg.path}");

            final storageController = StorageController();
            final downloadURL = await storageController.uploadImage(
                'Cars', "${user?.uid}_${pickedFile.name}", croppedImg);

            if (downloadURL.isNotEmpty) {
              _logger.i("Image uploaded successfully: $downloadURL");
              _imageUrls.add(downloadURL);
            } else {
              _logger.e("Failed to upload image");
            }
          } else {
            _logger.i("Cropping canceled or failed.");
          }
        } catch (e) {
          _logger.e('Error processing image: $e');
        }
      }

      setState(() {
        _photos = pickedFiles;
      });
      // ignore: unnecessary_null_comparison
    } else if (pickedFiles != null) {
      _logger.i('Picked more than 5 images');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can select up to 5 images only.'),
        ),
      );
    } else {
      _logger.i('No images picked.');
    }
  }

  Future<File?> cropImage(BuildContext context, File file) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressFormat: ImageCompressFormat.jpg,
        maxHeight: 512,
        maxWidth: 512,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: const Color.fromARGB(255, 158, 39, 146),
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      if (croppedFile != null) {
        _logger.i('Image cropped: ${croppedFile.path}');
        return File(croppedFile.path);
      } else {
        _logger.i('Image cropping was cancelled or failed.');
        return null;
      }
    } catch (e) {
      _logger.e('Error cropping image: $e');
      return null;
    }
  }

  Future<void> updateCar() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.car.id)
          .update({
        'carName': carNameController.text,
        'model': modelController.text,
        'year': int.parse(yearController.text),
        'price': double.parse(priceController.text),
        'mileage': int.parse(mileageController.text),
        'condition': conditionController.text,
        'tpnumber': int.parse(tpnumberController.text),
        'location': locationController.text,
        'description': descriptionController.text,
        'photos': _imageUrls,
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car updated')),
      );
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const ViewCarsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200, // Adjust height as needed
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      // ListView to display images or the "add" icon
                      _imageUrls.isEmpty
                          ? Center(
                              child: GestureDetector(
                                onTap:
                                    _pickImages, // Handle image picking when icon is tapped
                                child: Container(
                                  height: 150, // Adjust height as needed
                                  width: 150, // Adjust width as needed
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageUrls.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Image.network(
                                        _imageUrls[index],
                                        fit: BoxFit.cover,
                                        width: 150, // Adjust width as needed
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () {
                                          final String url = _imageUrls[index];
                                          Logger().i(
                                              _imageUrls); // Store the URL before deletion
                                          FirebaseStorage.instance
                                              .refFromURL(url)
                                              .delete()
                                              .then((_) {
                                            setState(() {
                                              // _photos!.removeAt(index);
                                              _imageUrls.removeAt(index);
                                            });

                                            Logger().i(
                                                'Deleted image from URL: $url');
                                            Logger()
                                                .i('downloadUrls: $_imageUrls');
                                          }).catchError((error) {
                                            if (error is FirebaseException &&
                                                error.code ==
                                                    'object-not-found') {
                                              Logger().e(
                                                  'Failed to delete image: No object exists at the desired reference.');
                                            } else {
                                              Logger().e(
                                                  'Failed to delete image: $error');
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      // FloatingActionButton to pick more images
                      Positioned(
                        top: 10,
                        right: 10,
                        child: FloatingActionButton(
                          onPressed: _pickImages,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: carNameController,
                decoration: InputDecoration(
                  labelText: 'Car Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the car name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: modelController,
                decoration: InputDecoration(
                  labelText: 'Model',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: yearController,
                decoration: InputDecoration(
                  labelText: 'Year',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: mileageController,
                decoration: InputDecoration(
                  labelText: 'Mileage',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mileage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: conditionController,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the condition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tpnumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: updateCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Update Car',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
