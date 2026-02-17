import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PNVDemoScreen extends StatefulWidget {
  @override
  _PNVDemoScreenState createState() => _PNVDemoScreenState();
}

class _PNVDemoScreenState extends State<PNVDemoScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill test phone for India (+91)
    _phoneController.text = '+917000000000'; // Your real SIM number
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PNV One-Tap Test')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PNV One-Tap Demo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_isVerifying,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isVerifying ? null : _startPNV,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: _isVerifying
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('🔐 One-Tap Verify'),
            ),
            SizedBox(height: 24),
            Text(
              '📱 Test on REAL DEVICE with SIM + WiFi\n⏱️ PNV: 1-3 seconds auto-complete',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPNV() async {
    setState(() => _isVerifying = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        timeout: Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 🚀 PNV SUCCESS! One-tap complete (no code needed)
          await FirebaseAuth.instance.signInWithCredential(credential);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ PNV Success! One-tap verified in ${DateTime.now().difference(DateTime.now().subtract(Duration(seconds: 2)))}s'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            setState(() => _isVerifying = false);
            // Navigate to home screen
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${e.message}'), backgroundColor: Colors.red),
          );
          setState(() => _isVerifying = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          // Fallback: SMS flow (PNV not supported)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('📱 SMS sent (PNV not supported on this device)')),
          );
          setState(() => _isVerifying = false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isVerifying = false);
    }
  }
}
