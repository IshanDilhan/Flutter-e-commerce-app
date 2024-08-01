import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:myapp/controllers/storage_controller.dart';
import 'package:myapp/providers/profile_provider.dart';
import 'package:myapp/screens/Admin/admin_page.dart';
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
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Consumer<UserInfoProvider>(
            builder: (context, userInfoProvider, child) {
          final imageURL = userInfoProvider.userInfo['imageURL'];
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
                              )
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
                    fontSize: 24,
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
                )
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        },
        child: const Icon(Icons.admin_panel_settings_sharp),
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
