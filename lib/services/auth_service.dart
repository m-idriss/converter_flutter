import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service class for handling Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _googleSignInInitialized = false;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the current user.
  User? get currentUser => _auth.currentUser;

  /// Ensures GoogleSignIn is initialized before use.
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    }
  }

  /// Sign in with email and password.
  /// 
  /// Returns [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create a new user with email and password.
  /// 
  /// Sets the display name from the email username (part before @) if not provided.
  /// Returns [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Set display name from email username
    final username = email.split('@').first;
    await credential.user?.updateDisplayName(username);
    
    return credential;
  }

  /// Sign in with Google.
  /// 
  /// Returns [UserCredential] on success, null if user cancelled.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    
    try {
      // Trigger the Google Sign-In flow using the singleton pattern
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Obtain the id token from authentication
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Google authentication did not return a valid ID token.',
        );
      }

      // Request authorization for scopes to get the access token
      // These are the minimal scopes needed for Firebase Auth.
      // Note: 'openid' is typically included by default in OAuth 2.0 flows and may not need to be specified explicitly.
      const scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ];
      final authorization = await googleUser.authorizationClient.authorizeScopes(scopes);
      final String accessToken = authorization.accessToken;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in to Firebase with the credential
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // User cancelled the sign-in flow
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  /// Sign out the current user.
  /// 
  /// Signs out from both Google (if applicable) and Firebase.
  /// Ensures Firebase signOut completes even if Google signOut fails.
  Future<void> signOut() async {
    // Try to sign out from Google, but don't let it block Firebase signOut
    try {
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Ignore Google signOut errors - user may have signed in with email/password
    }
    // Always sign out from Firebase
    await _auth.signOut();
  }

  /// Get a user-friendly error message from FirebaseAuthException.
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
