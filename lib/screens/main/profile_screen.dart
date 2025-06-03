import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;

  File? _imageFile;
  Position? _currentPosition;
  String? _locationString;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController();

    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _contactController.text = data['contact'] ?? '';
        if (data['location'] != null) {
          _latitude = data['location']['latitude'];
          _longitude = data['location']['longitude'];
          _locationString = 'Lat: $_latitude, Lng: $_longitude';
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationString = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
    });
  }

  Future<void> _selectLocationOnMap() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        LatLng selectedLatLng = LatLng(
          _latitude ?? 7.8731,
          _longitude ?? 80.7718,
        );

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: selectedLatLng,
                        zoom: 6,
                      ),
                      onTap: (LatLng position) {
                        setModalState(() {
                          selectedLatLng = position;
                        });
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("selected"),
                          position: selectedLatLng,
                        ),
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _latitude = selectedLatLng.latitude;
                        _longitude = selectedLatLng.longitude;
                        _locationString =
                            'Lat: ${selectedLatLng.latitude}, Lng: ${selectedLatLng.longitude}';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Confirm Location"),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _uploadImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pics')
        .child('${user.uid}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      String? photoUrl = user.photoURL;
      if (_imageFile != null) {
        photoUrl = await _uploadImage(_imageFile!);
        await user.updatePhotoURL(photoUrl);
      }
      await user.updateDisplayName(_nameController.text);

      final userData = {
        'contact': _contactController.text,
        'location':
            (_latitude != null && _longitude != null)
                ? {'latitude': _latitude, 'longitude': _longitude}
                : null,
      };
      userData.removeWhere((key, value) => value == null);

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final imageProvider =
        _imageFile != null
            ? FileImage(_imageFile!)
            : (user?.photoURL != null && user!.photoURL!.isNotEmpty)
            ? NetworkImage(user.photoURL!)
            : const AssetImage('assets/images/guy.jpg') as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 60, backgroundImage: imageProvider),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('Name', _nameController),
            _buildTextField('Email', _emailController, enabled: false),
            _buildTextField(
              'Contact Number',
              _contactController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locationString ?? 'No location selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _getCurrentLocation,
                      child: const Text('Use Current'),
                    ),
                    TextButton(
                      onPressed: _selectLocationOnMap,
                      child: const Text('Select Location'),
                    ),
                  ],
                ),
              ],
            ),
            if (_latitude != null && _longitude != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_latitude!, _longitude!),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: LatLng(_latitude!, _longitude!),
                      ),
                    },
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {},
                  ),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 129, 234, 92),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
