import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '556026049349-sqsm07dmla41k1tac0qak39nbu3cedg9.apps.googleusercontent.com',
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  const AuthResult({required this.success, this.error, this.user});
}

class AuthController extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    final auth = ref.watch(firebaseAuthProvider);
    auth.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
    return AsyncValue.data(auth.currentUser);
  }

  /// Ensures an active user session exists (anonymously if not logged in)
  /// so users can immediately bookmark and track progress.
  Future<User?> ensureAuthenticated() async {
    final auth = ref.read(firebaseAuthProvider);
    if (auth.currentUser != null) {
      return auth.currentUser;
    }
    try {
      final cred = await auth.signInAnonymously();
      return cred.user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Sign In with Email and Password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      final cred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = AsyncValue.data(cred.user);
      return AuthResult(success: true, user: cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Register with Full Name, Email and Password
  Future<AuthResult> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (cred.user != null && name.trim().isNotEmpty) {
        await cred.user!.updateDisplayName(name.trim());
        await cred.user!.reload();
      }
      state = AsyncValue.data(auth.currentUser);
      return AuthResult(success: true, user: auth.currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Sign In Anonymously (Guest Mode)
  Future<AuthResult> signInAnonymously() async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      final cred = await auth.signInAnonymously();
      state = AsyncValue.data(cred.user);
      return AuthResult(success: true, user: cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Send Password Reset Email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Sign In or Sign Up with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await auth.signInWithPopup(googleProvider);
      } else {
        final googleSignIn = ref.read(googleSignInProvider);
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return const AuthResult(
            success: false,
            error: 'গুগল সাইন-ইন বাতিল করা হয়েছে।',
          );
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final currentUser = auth.currentUser;
        if (currentUser != null && currentUser.isAnonymous) {
          try {
            userCredential = await currentUser.linkWithCredential(credential);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'credential-already-in-use') {
              userCredential = await auth.signInWithCredential(credential);
            } else {
              rethrow;
            }
          }
        } else {
          userCredential = await auth.signInWithCredential(credential);
        }
      }

      state = AsyncValue.data(userCredential.user);
      return AuthResult(success: true, user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In FirebaseAuthException: [${e.code}] ${e.message}');
      return AuthResult(success: false, error: _mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('Google Sign-In Exception: $e\n$st');
      String userMessage =
          'গুগল অ্যাকাউন্টে সাইন-ইন করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      final errorStr = e.toString();
      if (errorStr.contains('10') || errorStr.contains('DEVELOPER_ERROR')) {
        userMessage =
            'গুগল সাইন-ইন কনফিগারেশন ত্রুটি (API 10)। ফায়ারবেস কনসোলে SHA-1 ফিংগারপ্রিন্ট যাচাই করুন।';
      } else if (errorStr.contains('12500')) {
        userMessage =
            'গুগল প্লে সার্ভিসেস ত্রুটি (12500)। আপনার ডিভাইসের গুগল প্লে সার্ভিসেস আপডেট করুন।';
      } else if (errorStr.contains('network') || errorStr.contains('Network')) {
        userMessage = 'ইন্টারনেট সংযোগ পাওয়া যায়নি। ইন্টারনেট সংযোগ চেক করুন।';
      }
      return AuthResult(
        success: false,
        error: kDebugMode ? '$userMessage\n($e)' : userMessage,
      );
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    final auth = ref.read(firebaseAuthProvider);
    try {
      if (!kIsWeb) {
        final googleSignIn = ref.read(googleSignInProvider);
        await googleSignIn.signOut();
      }
    } catch (_) {}
    await auth.signOut();
    state = const AsyncValue.data(null);
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'এই ইমেইল দিয়ে কোনো অ্যাকাউন্ট পাওয়া যায়নি।';
      case 'wrong-password':
        return 'ভুল পাসওয়ার্ড প্রদান করেছেন। অনুগ্রহ করে আবার চেষ্টা করুন।';
      case 'invalid-email':
        return 'সঠিক ইমেইল ঠিকানা প্রদান করুন।';
      case 'user-disabled':
        return 'এই অ্যাকাউন্টটি নিষ্ক্রিয় করা হয়েছে।';
      case 'too-many-requests':
        return 'অতিরিক্ত ব্যর্থ চেষ্টার কারণে সাময়িকভাবে ব্লক করা হয়েছে। কিছুক্ষণ পর চেষ্টা করুন।';
      case 'invalid-credential':
        return 'ইমেইল বা পাসওয়ার্ড সঠিক নয়। দয়া করে আবার চেষ্টা করুন।';
      case 'email-already-in-use':
        return 'এই ইমেইল ঠিকানাটি দিয়ে ইতিমধ্যে একটি অ্যাকাউন্ট রয়েছে। লগইন করুন।';
      case 'account-exists-with-different-credential':
        return 'এই ইমেইলটি দিয়ে অন্য মাধ্যমে অ্যাকাউন্ট খোলা হয়েছে। অনুগ্রহ করে সেই মাধ্যমে সাইন-ইন করুন।';
      case 'credential-already-in-use':
        return 'এই গুগল অ্যাকাউন্টটি ইতিমধ্যে অন্য একটি প্রোফাইলে ব্যবহৃত হচ্ছে।';
      case 'popup-closed-by-user':
        return 'পপ-আপ বন্ধ করা হয়েছে। আবার চেষ্টা করুন।';
      case 'weak-password':
        return 'পাসওয়ার্ডটি দুর্বল। কমপক্ষে ৬টি অক্ষরের শক্তিশালী পাসওয়ার্ড দিন।';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ পাওয়া যায়নি। ইন্টারনেট চেক করে আবার চেষ্টা করুন।';
      case 'operation-not-allowed':
        return 'এই সাইন-ইন পদ্ধতিটি ফায়ারবেসে সক্রিয় করা নেই।';
      default:
        return e.message ?? 'একটি অপ্রত্যাশিত সমস্যা হয়েছে। আবার চেষ্টা করুন।';
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<User?>>(AuthController.new);
