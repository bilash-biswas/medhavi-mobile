import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
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

  /// Sign Out
  Future<void> signOut() async {
    final auth = ref.read(firebaseAuthProvider);
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
