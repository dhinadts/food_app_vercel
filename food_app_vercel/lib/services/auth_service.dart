import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  static final AuthService _singleton = AuthService._internal();

  factory AuthService() => _singleton;

  AuthService._internal();

  void init() {
    // placeholder for any initialization
  }

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final cred = await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> signUp(String email, String password) async {
    final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'orders': [],
      'preferences': [],
    });
    return cred.user;
  }


Future<User?> signInWithGoogle() async {
   final GoogleSignIn googleSignIn = GoogleSignIn();

  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with the credential
    final UserCredential userCred = await auth.signInWithCredential(credential);
    final User? user = userCred.user;

    // Ensure Firestore user document exists
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'orders': [],
        'preferences': [],
      }, SetOptions(merge: true));
    }

    return user;
  } catch (e) {
    print('Google sign-in failed: $e');
    return null;
  }
}
  
  
  
  
  Future<void> signOut() => auth.signOut();

  Future<void> saveOrder(String uid, Map<String, dynamic> order) async {
    final ref = _firestore.collection('users').doc(uid);
    await ref.update({
      'orders': FieldValue.arrayUnion([order])
    });
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.exists ? snap.data() : null;
  }
}
