import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  static final AuthService _singleton = AuthService._internal();
  factory AuthService() => _singleton;
  AuthService._internal();

  void init() {
    // placeholder for any initialization
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'orders': [],
      'preferences': [],
    });
    return cred.user;
  }

  Future<User?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _auth.signInWithCredential(credential);
    // ensure user doc
    await _firestore.collection('users').doc(userCred.user!.uid).set({
      'email': userCred.user!.email,
      'createdAt': FieldValue.serverTimestamp(),
      'orders': [],
      'preferences': [],
    }, SetOptions(merge: true));
    return userCred.user;
  }

  Future<void> signOut() => _auth.signOut();

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
