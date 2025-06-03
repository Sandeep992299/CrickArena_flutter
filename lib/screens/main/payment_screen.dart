import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isProcessing = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
        );
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Column(
        children: [
          // Header with yellow background and curved edges
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
                  onPressed: _onBackPressed,
                ),
              ),
              const Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Secure Payment',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
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

          // Main content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child:
                  _isProcessing
                      ? Center(
                        child: Lottie.asset(
                          'assets/animations/loading.json',
                          width: 150,
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/credit_card.json',
                              height: 150,
                            ),
                            const SizedBox(height: 20),
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Enter Card Details',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            107,
                                            236,
                                            75,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Card Number',
                                          prefixIcon: const Icon(
                                            Icons.credit_card,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        maxLength: 16,
                                        validator:
                                            (value) =>
                                                value!.length != 16
                                                    ? 'Enter valid card number'
                                                    : null,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Card Holder Name',
                                          prefixIcon: const Icon(Icons.person),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        validator:
                                            (value) =>
                                                value!.isEmpty
                                                    ? 'Name is required'
                                                    : null,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                labelText: 'Expiry MM/YY',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              validator:
                                                  (value) =>
                                                      value!.isEmpty
                                                          ? 'Required'
                                                          : null,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                labelText: 'CVV',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              obscureText: true,
                                              maxLength: 3,
                                              validator:
                                                  (value) =>
                                                      value!.length != 3
                                                          ? 'Invalid CVV'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _processPayment,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  111,
                                                  244,
                                                  93,
                                                ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 3,
                                          ),
                                          icon: const Icon(Icons.lock),
                                          label: const Text(
                                            'Pay Securely',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
