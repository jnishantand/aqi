import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _forceResendingToken;

  //  Expose auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //  Expose current user
  User? get currentUser => _auth.currentUser;

  //  Send OTP method
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          print(' Auto-retrieval successful');
          await _auth.signInWithCredential(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          String error = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            error = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            error = 'Too many attempts. Try later.';
          } else if (e.code == 'missing-client-identifier') {
            error = 'OAuth branding not completed';
          } else if (e.code == 'network-request-failed') {
            error = 'Network error. Check connection.';
          }
          print(' Error: $error - ${e.message}');
          onError(error);
        },

        codeSent: (String verificationId, int? resendToken) {
          print(' Code sent successfully');
          _verificationId = verificationId;
          _forceResendingToken = resendToken;
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          print(' Auto-retrieval timeout');
          _verificationId = verificationId;
        },

        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print(' Unexpected error: $e');
      onError('Unexpected error occurred');
    }
  }

  //  Verify OTP method
  Future<User?> verifyOTP({
    required String smsCode,
    required Function(String) onError,
  }) async {
    try {
      if (_verificationId == null) {
        onError('No verification ID found. Request OTP first.');
        return null;
      }

      print('🔐 Verifying OTP: $smsCode');

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      print(' User signed in: ${userCredential.user?.phoneNumber}');
      return userCredential.user;

    } catch (e) {
      print(' OTP verification error: $e');

      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          onError('Invalid OTP code. Please try again.');
        } else if (e.code == 'session-expired') {
          onError('Code expired. Request new OTP.');
        } else {
          onError('Error: ${e.message}');
        }
      } else {
        onError('Error verifying code');
      }
      return null;
    }
  }

  //  Resend OTP method
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _forceResendingToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _forceResendingToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError('Error resending code');
    }
  }

  //  Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _forceResendingToken = null;
  }
}