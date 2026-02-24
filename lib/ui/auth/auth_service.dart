import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In");

      await _googleSignIn.initialize(
        serverClientId:
        "45777911778-5nkotpqc610prekmf1nk70d2141ph741.apps.googleusercontent.com",
      );

      final account = await _googleSignIn.authenticate();

      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw Exception("ID Token is null");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final result =
      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Firebase Login Success");
      return result;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }


}
