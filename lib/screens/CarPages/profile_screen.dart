import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:myapp/controllers/storage_controller.dart';
import 'package:myapp/providers/profile_provider.dart';
import 'package:myapp/screens/Admin/add_item.dart';
import 'package:myapp/screens/Admin/admin_page.dart';
import 'package:myapp/screens/Admin/payment_details.dart';
import 'package:myapp/screens/Sign_In_Pages/login_page.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController editusernamecontroler = TextEditingController();

  String? filepath;
  String? profileImageUrl;
  XFile? pickedFile;
  User? user;

  final ImagePicker _picker = ImagePicker();

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Delay for the sign-out to be processed before navigating
      await Future.delayed(const Duration(milliseconds: 3500));

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      Logger().e('Error during logout: $e');
    }
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({'username': newUsername});
        // Optionally, you can show a success message or handle post-update logic here

        // ignore: use_build_context_synchronously
        context
            .read<UserInfoProvider>()
            .updateUserInfo('username', newUsername);
        Logger().i('username updated');
        editusernamecontroler.clear();
      } catch (e) {
        // Handle errors here, for example by showing an error message
        Logger().i('Failed to update username: $e');
      }
    } else {
      // Handle the case where no user is signed in
      Logger().i('No user is signed in.');
    }
  }

  Future<void> deleteImage(String imageurl) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({'imageURL': 'https://www.gravatar.com/avatar?d=mp'});

        // Update UserInfoProvider
        // ignore: use_build_context_synchronously
        context
            .read<UserInfoProvider>()
            .updateUserInfo('imageURL', 'https://www.gravatar.com/avatar?d=mp');

        Logger().i('Image URL deleted successfully');

        // Ensure the widget is still mounted before calling setState
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        // Handle specific errors or display an error message
        Logger().e('Failed to delete image URL: $e');
      }
    } else {
      // Handle the case where no user is signed in
      Logger().i('No user is signed in.');
    }
  }

  Future<void> updateProfileimagelink(String imageURL) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({'imageURL': imageURL});

        // ignore: use_build_context_synchronously
        context.read<UserInfoProvider>().updateUserInfo('imageURL', imageURL);

        Logger().i('imageURL updated');
      } catch (e) {
        // Handle errors here, for example by showing an error message
        Logger().i('Failed to update imageURL: $e');
      }
    } else {
      // Handle the case where no user is signed in
      Logger().i('No user is signed in.');
    }
  }

  Future<void> selectImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        Logger().i('Image selected: ${pickedFile?.path}');

        File? croppedImg =
            // ignore: use_build_context_synchronously
            await cropImage(context, File(pickedFile?.path as String));
        if (croppedImg != null) {
          Logger().i("Cropped correctly: ${croppedImg.path}");
          setState(() {
            // Update the state to refresh the UI
            filepath = croppedImg.path;
          });
          final storageController = StorageController();
          final downloadURL = await storageController.uploadImage(
              'images', "${user?.uid}.jpg", croppedImg);

          if (downloadURL.isNotEmpty) {
            Logger().i("Image uploaded successfully: $downloadURL");
            updateProfileimagelink(downloadURL);
          } else {
            Logger().e("Failed to upload image");
          }
        } else {
          Logger().i("Cropping canceled or failed.");
        }
      } else {
        Logger().i('Image selection was cancelled or failed.');
      }
    } catch (e) {
      Logger().e('Error selecting image: $e');
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

  Future<void> deleteUserAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Delete all images associated with the user
        await _deleteUserImages(user.uid);

        // Delete user document from Firestore
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .delete();

        // Sign the user out
        await FirebaseAuth.instance.signOut();

        // Navigate to the login page
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );

        Logger().i('User account and associated images deleted successfully.');
      } catch (e) {
        Logger().e('Failed to delete user account: $e');
        // Show an error message if needed
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Future<void> _deleteUserImages(String userId) async {
    // Assuming the images are stored with the userId as part of the path
    final imageRef =
        FirebaseStorage.instance.ref().child('images').child('$userId.jpg');

    try {
      // Delete the profile image
      await imageRef.delete();
      Logger().i('Profile image deleted successfully.');
    } catch (e) {
      Logger().e('Failed to delete profile image: $e');
      // Handle specific errors if needed
    }

    // If there are other images, delete them similarly
    // You can add additional logic to delete other images related to the user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Consumer<UserInfoProvider>(
            builder: (context, userInfoProvider, child) {
          String imageURL = userInfoProvider.userInfo['imageURL'];
          final username = userInfoProvider.userInfo['username'];
          final email = userInfoProvider.userInfo['email'];
          return Center(
            child: Column(
              children: [
                // Background Image Container
                SizedBox(
                  height: 200,
                  child: Stack(children: [
                    Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/2.jpg"),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        selectImage();
                      },
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              // ignore: unnecessary_null_comparison
                              imageURL != null && imageURL.isNotEmpty
                                  ? NetworkImage(
                                      imageURL) // Use NetworkImage for URL
                                  : const NetworkImage(
                                      "https://www.gravatar.com/avatar?d=mp"),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        selectImage();
                                      },
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            Colors.black.withOpacity(0.5),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 8), // Spacing between buttons
                                    (imageURL !=
                                            'https://www.gravatar.com/avatar?d=mp')
                                        ? GestureDetector(
                                            onTap: () {
                                              deleteImage(imageURL);
                                            },
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor:
                                                  Colors.red.withOpacity(0.5),
                                              child: const Icon(
                                                Icons.delete,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : const SizedBox
                                            .shrink(), // Hide the button when the condition is met
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                // Profile Image Container

                const SizedBox(height: 16),
                // Name
                Text(
                  username ??
                      'Loading...', // Replace with dynamic data if needed
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email ?? 'Loading...', // Replace with dynamic data if needed
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                ElevatedButton(
                  onPressed: () {
                    // Logout logic here
                    _logout(context);
                  },
                  child: const Text('Logout'),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      TextField(
                        controller: editusernamecontroler,
                        decoration: const InputDecoration(
                          labelText: "User Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                          height:
                              20), // Increased spacing for better visual separation
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Background color of the button
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0), // Padding inside the button
                        ),
                        onPressed: () async {
                          String newUsername = editusernamecontroler.text;
                          try {
                            await updateUsername(newUsername);
                            // Refresh user data after update

                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Username updated successfully!')),
                            );
                          } catch (error) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to update username: $error')),
                            );
                          }
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white), // Adjusted text style
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminPage()),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings,
                        color: Colors.white),
                    label: const Text(
                      'Admin Page',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 40, 59, 97), // Light blue background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0), // Adjust padding as needed
                    ),
                  ),
                ),
                const SizedBox(height: 5), // Add spacing between buttons

                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentDetailsPage()),
                      );
                    },
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text(
                      'Payments',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 40, 59, 97), // Light blue background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0), // Adjust padding as needed
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    // Logout logic here
                    deleteUserAccount(context);
                  },
                  icon: const Icon(Icons.delete,
                      color: Colors.white), // Add your desired icon here
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red, // Text color
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddItemPage()),
          );
        },
        child: const Icon(Icons.add),
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
