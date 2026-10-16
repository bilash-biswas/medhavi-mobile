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

  Future<void> signOut() async {
    final auth = ref.read(firebaseAuthProvider);
    await auth.signOut();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<User?>>(AuthController.new);
