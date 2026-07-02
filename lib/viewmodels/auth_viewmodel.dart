import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:app/models/data/repositories/user_repository.dart';
import 'package:app/models/user.dart' as app_model;

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepo = UserRepository();

  User? _user;
  app_model.User? _appUser;
  bool _isLoading = false;
  bool _isGuest = false;
  String? _errorMessage;

  User? get user => _user;
  app_model.User? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _isGuest;
  bool get isAdmin => _appUser?.role == 'admin';
  String? get errorMessage => _errorMessage;

  Future<String?> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await _userRepo.initializeUserProfile(userCredential.user!);
        _appUser = await _userRepo.getCurrentUserProfile();
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Anonymous Auth Error: $e');
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AuthViewModel() {
    _auth.authStateChanges().listen((user) async {
      debugPrint('🔐 AuthViewModel: Auth state changed. User: ${user?.uid}');
      _user = user;
      if (user != null) {
        _isGuest = false;
        // Fetch app user profile
        try {
          debugPrint('🔐 AuthViewModel: Fetching user profile...');
          _appUser = await _userRepo.getCurrentUserProfile();
          debugPrint(
            '🔐 AuthViewModel: User profile fetched: ${_appUser?.displayName}',
          );
        } catch (e) {
          debugPrint('🔐 AuthViewModel: Error fetching app user: $e');
        }
      } else {
        _appUser = null;
      }
      notifyListeners();
      debugPrint(
        '🔐 AuthViewModel: Notified listeners. isLoggedIn: $isLoggedIn',
      );
    });
  }

  Future<String?> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Connection timed out. Please check your internet.',
          );
        },
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        case 'invalid-credential':
          message = 'Incorrect email or password';
          break;
        case 'network-request-failed':
          message = 'No internet connection. Please check your network.';
          break;
        default:
          message = e.message ?? 'Authentication failed';
      }
      _errorMessage = message;
      debugPrint('Auth Error: ${e.code} - ${e.message}');
      return message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Unknown Error: $e');
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signUpWithEmail(
    String email,
    String password,
    String name,
    String username,
    String phone,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        _user = _auth.currentUser;

        // Initialize user profile in Firestore
        if (_user != null) {
          await _userRepo.initializeUserProfile(
            _user!,
            username: username,
            phone: phone,
          );
          _appUser = await _userRepo.getCurrentUserProfile();
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-up is not enabled';
          break;
        default:
          message = e.message ?? 'Sign up failed';
      }
      _errorMessage = message;
      debugPrint('SignUp Auth Error: ${e.code} - ${e.message}');
      return message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('SignUp Unknown Error: $e');
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // This method integrates the Google Sign-In API to authenticate users.
  // It exchanges user credentials with Firebase Auth.
  Future<String?> signInWithGoogle([String? languageCode]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (languageCode != null) {
      _auth.setLanguageCode(languageCode);
    }

    try {
      // 1. Trigger Google Sign-In Flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Sign in cancelled';
        return 'Google sign in was cancelled';
      }

      // 2. Obtain Auth Details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      debugPrint('🔐 AuthViewModel: Signing in to Firebase...');
      final userCredential =
          await _auth.signInWithCredential(credential).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Connection timed out. Please check your internet.',
          );
        },
      );
      debugPrint(
        '🔐 AuthViewModel: Firebase sign in successful: ${userCredential.user?.uid}',
      );

      // Initialize profile if new user
      if (userCredential.user != null) {
        debugPrint('🔐 AuthViewModel: Initializing user profile...');
        await _userRepo.initializeUserProfile(userCredential.user!);
        _appUser = await _userRepo.getCurrentUserProfile();
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Google Auth Error: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Account exists with different sign-in method';
          break;
        case 'invalid-credential':
          message = 'Invalid Google credentials. Please try again';
          break;
        case 'operation-not-allowed':
          message = 'Google Sign-In is not enabled. Please contact support';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = e.message ?? 'Google sign in failed';
      }
      _errorMessage = message;
      return message;
    } catch (e) {
      debugPrint('❌ Google Sign-In Unknown Error: $e');
      _errorMessage = 'Failed to sign in with Google. Please try again';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
      _isGuest = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
      _errorMessage = 'Failed to sign out';
    }
  }

  Future<bool> promoteToAdmin(String key) async {
    if (key != 'admin123') return false;

    if (_user != null) {
      await _userRepo.updateUserRole(_user!.uid, 'admin');

      _appUser = await _userRepo.getCurrentUserProfile();
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Profile Updates ---

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_user != null) {
        // Update display name in Auth
        await _user!.updateDisplayName(name);
        await _user!.reload();
        _user = _auth.currentUser;

        // Update profile in Firestore
        await _userRepo.saveUserProfile(
            name: name, phone: phone, username: username);

        // Refresh app user data
        _appUser = await _userRepo.getCurrentUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Update Profile Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
