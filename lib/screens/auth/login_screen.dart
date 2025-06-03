import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError('Login failed: ${e.toString()}');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError("Google sign-in failed: ${e.toString()}");
    }
  }

  Future<void> _authenticateBiometric() async {
    try {
      final isSupported = await auth.isDeviceSupported();
      final available = await auth.getAvailableBiometrics();

      if (!isSupported || available.isEmpty) {
        _showError("Biometric authentication not available on this device.");
        return;
      }

      final didAuth = await auth.authenticate(
        localizedReason: 'Authenticate using biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuth) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError('Biometric authentication failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/CRrgan 1.png', height: 120),
                const SizedBox(height: 30),
                const Text(
                  "Sign into your account",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  Icons.email,
                  "Email",
                  _emailController,
                  maxWidth,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  Icons.lock,
                  "Password",
                  _passwordController,
                  maxWidth,
                  isPassword: true,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: maxWidth,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(
                      'assets/images/google_icon.png',
                      _signInWithGoogle,
                    ),
                    const SizedBox(width: 20),
                    _socialButton(
                      'assets/images/bio.png',
                      _authenticateBiometric,
                    ),
                    const SizedBox(width: 20),
                    _socialButton(
                      'assets/images/face_id.png',
                      _authenticateBiometric,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: maxWidth,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Skip', style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint,
    TextEditingController controller,
    double maxWidth, {
    bool isPassword = false,
  }) {
    return SizedBox(
      width: maxWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            icon: Icon(icon),
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 24,
        child: Image.asset(imagePath, height: 30, width: 30),
      ),
    );
  }
}
