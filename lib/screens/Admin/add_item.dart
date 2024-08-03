import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:myapp/controllers/storage_controller.dart';
import 'dart:io';

import 'package:myapp/models/car_model.dart';
import 'package:myapp/screens/Admin/carview.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _tpnumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _photos = [];
  List<String> downloadUrls = [];

  final Logger _logger = Logger();
  void _clearAllFields() {
    _carNameController.clear();
    _modelController.clear();
    _yearController.clear();
    _priceController.clear();
    _mileageController.clear();
    _conditionController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _photos?.clear();
  }

  Future<void> _pickImages() async {
    User? user = FirebaseAuth.instance.currentUser;
    _logger.i('Picking images...');
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 85);

    // ignore: unnecessary_null_comparison
    if (pickedFiles != null && pickedFiles.length <= 5) {
      _logger.i('Picked ${pickedFiles.length} images');

      // Create a list to store the download URLs

      for (XFile pickedFile in pickedFiles) {
        try {
          File file = File(pickedFile.path);

          // Crop each image if needed
          // ignore: use_build_context_synchronously
          File? croppedImg = await cropImage(context, file);

          if (croppedImg != null) {
            _logger.i("Cropped correctly: ${croppedImg.path}");

            // Upload the cropped image
            final storageController = StorageController();
            final downloadURL = await storageController.uploadImage(
                'Cars', "${user?.uid}_${pickedFile.name}", croppedImg);

            if (downloadURL.isNotEmpty) {
              _logger.i("Image uploaded successfully: $downloadURL");
              downloadUrls.add(downloadURL);
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
        // Store or use the download URLs as needed
        // Example: _imageUrls = downloadUrls;
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
              CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
            ],
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      if (croppedFile != null) {
        Logger().i('Image cropped: ${croppedFile.path}');
        return File(croppedFile.path);
      } else {
        Logger().i('Image cropping was cancelled or failed.');
        return null;
      }
    } catch (e) {
      Logger().e('Error cropping image: $e');
      return null;
    }
  }

  Future<void> _saveCar() async {
    _logger.i('Saving car...');

    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.i('User not logged in');
        // Handle user not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in!'),
          ),
        );
        return;
      }

      try {
        // Parse numeric fields
        final int year = int.parse(_yearController.text);
        final double price = double.parse(_priceController.text);
        final int mileage = int.parse(_mileageController.text);
        final int tpnumber = int.parse(_tpnumberController.text);

        // Create CarModel instance
        final car = CarModel(
          id: FirebaseFirestore.instance.collection('cars').doc().id,
          userId: user.uid,
          carName: _carNameController.text,
          model: _modelController.text,
          year: year,
          price: price,
          mileage: mileage,
          tpnumber: tpnumber,
          condition: _conditionController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          photos: downloadUrls,
        );
        // Logger().t(car.tpnumber);
        _logger.i('Storing car data in Firestore...');
        await FirebaseFirestore.instance
            .collection('cars')
            .doc(car.id)
            .set(car.toJson());

        _logger.i('Car added successfully');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car added successfully!'),
          ),
        );

        // Clear the form
        _logger.i('Resetting form...');
        _formKey.currentState!.reset();
        _clearAllFields();
        setState(() {
          _photos = [];
        });
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const ViewCarsPage()),
        );
      } catch (e) {
        // Handle parsing errors
        _logger.e('Error occurred: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enter valid numeric values for year, price,phonenumber, and mileage.'),
          ),
        );
      }
    } else {
      _logger.i('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    const appBarHeight = 20.0; // Adjusted height for the AppBar

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: Colors.purple,
          elevation: 0,
          flexibleSpace: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 30.0), // Adjusted top padding
              child: Text(
                "Add Your Car",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker section
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
                      _photos == null || _photos!.isEmpty
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
                              itemCount: _photos?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Image.file(
                                        File(_photos![index].path),
                                        fit: BoxFit.cover,
                                        width: 150, // Adjust width as needed
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () {
                                          final String url = downloadUrls[
                                              index]; // Store the URL before deletion
                                          FirebaseStorage.instance
                                              .refFromURL(url)
                                              .delete()
                                              .then((_) {
                                            setState(() {
                                              _photos!.removeAt(index);
                                              downloadUrls.removeAt(index);
                                            });

                                            Logger().i(
                                                'Deleted image from URL: $url');
                                            Logger().i(
                                                'downloadUrls: $downloadUrls');
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

              const SizedBox(height: 20.0),
              const Text(
                "Car Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              // Two-column layout for short answer fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                        _carNameController, "Car Name", Icons.directions_car),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _buildTextFormField(
                        _modelController, "Model", Icons.directions_car),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                        _yearController, "Year", Icons.calendar_today),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _buildTextFormField(
                        _priceController, "Price", Icons.attach_money,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                        _mileageController, "Mileage", Icons.speed,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _buildTextFormField(
                        _conditionController, "Condition", Icons.star),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              _buildTextFormField(
                  _tpnumberController, "Phone number", Icons.phone,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10.0),

              _buildTextFormField(
                  _locationController, "Location", Icons.location_on),
              const SizedBox(height: 10.0),
              _buildTextFormField(
                  _descriptionController, "Description", Icons.description,
                  maxLines: 10, minLines: 3), // Multiline description field
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveCar();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Background color
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    TextInputType? keyboardType,
    int? maxLines,
    int? minLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.purple.shade50,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      minLines: minLines ?? 1,
      textAlignVertical: TextAlignVertical.bottom,

      // Vertically centers the text
      textAlign: TextAlign.start, // Horizontally centers the text
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
