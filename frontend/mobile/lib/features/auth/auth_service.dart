/// Firebase Auth service layer for UnityHub.
///
/// Provides two auth pathways:
///   - Volunteers: Anonymous sign-in (simulates DigiLocker — no Google account needed).
///   - NGO Admins: Google Sign-In via Firebase Auth.
///
/// The resulting Firebase User UID is stored in [firebaseUserProvider] and used
/// downstream to link wallet addresses with KYC ImpactIDs.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Providers ────────────────────────────────────────────────────────────────

/// Streams the current Firebase [User] — null when signed out.
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Exposes the Firebase UID string, or null when unauthenticated.
final firebaseUidProvider = Provider<String?>((ref) {
  return ref.watch(firebaseAuthProvider).valueOrNull?.uid;
});

/// The Firebase Auth service singleton.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth Service ─────────────────────────────────────────────────────────────

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  /// Anonymous sign-in — used for volunteers to simulate DigiLocker identity.
  /// In production this would be replaced by the full PKCE + mTLS flow.
  Future<UserCredential> signInAnonymously() async {
    return _auth.signInAnonymously();
  }

  /// Google OAuth sign-in — used for NGO admins and sponsors.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Signs out from both Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Returns the Firebase ID token for the current user.
  /// This can be sent as a Bearer token to the FastAPI backend for server-side
  /// verification when DEMO_MODE is disabled.
  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }
}
