import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State variables
  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  File? _profileImage;
  File? get profileImage => _profileImage;

  final ImagePicker _picker = ImagePicker();

  void toggleAgreeToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  Future<String?> signUp() async {
    // Validation checks
    if (!_agreedToTerms) {
      return 'You must agree to the terms and policy';
    }

    if (passwordController.text != confirmPasswordController.text) {
      return 'Passwords do not match';
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        contactController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return 'Please fill all fields';
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String? uploadedImageUrl;
      if (_profileImage != null) {
        uploadedImageUrl = await _uploadImageToFirebase(_profileImage!);
      }

      // Update user profile
      await userCredential.user?.updateDisplayName(nameController.text.trim());
      if (uploadedImageUrl != null) {
        await userCredential.user?.updatePhotoURL(uploadedImageUrl);
      }

      // Save additional user info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
            'username': nameController.text.trim(),
            'email': emailController.text.trim(),
            'contact': contactController.text.trim(),
            'photoURL': uploadedImageUrl,
            'createdAt': Timestamp.now(),
          });

      return null; // Success, no error message
    } catch (e) {
      return 'Signup failed: ${e.toString()}';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
