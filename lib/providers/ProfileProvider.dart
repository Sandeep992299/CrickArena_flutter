import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController contactController;

  File? profileImage;
  LatLng? pickedLocation;

  ProfileProvider() {
    nameController = TextEditingController(text: user?.displayName ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    contactController = TextEditingController(text: '');
    // Load additional user data like contact number and location from your database here
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    pickedLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  Future<void> saveProfile() async {
    // Update Firebase user profile
    if (user != null) {
      await user!.updateDisplayName(nameController.text);
      // Upload profileImage to storage and get URL, then:
      // await user!.updatePhotoURL(photoURL);
    }

    // Save contact number and location to your database
    // Example: Firestore or Realtime Database
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }
}
