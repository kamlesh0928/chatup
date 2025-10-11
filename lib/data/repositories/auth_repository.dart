import 'dart:developer';
import 'package:chatup/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/base_repository.dart';

class AuthRepository extends BaseRepository {
  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserModel> signup({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
        RegExp(r'\s+'),
        "".trim(),
      );

      final usernameExists = await checkUsernameExists(username);
      if (usernameExists) {
        throw "Username already exists";
      }

      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        throw "Email already exists";
      }

      final phoneNumberExists = await checkPhoneExists(formattedPhoneNumber);
      if (phoneNumberExists) {
        throw "Phone number already exists";
      }

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw "Failed to create user";
      }

      final user = UserModel(
        uid: userCredential.user!.uid,
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: formattedPhoneNumber,
      );

      await saveUserToFirestore(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw "User not found";
      }

      final user = await getUserFromFirestore(userCredential.user!.uid);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final querySnapshot = await firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking username existence: $e");
      return false;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking email existence: $e");
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phone) async {
    try {
      final formattedPhoneNumber = phone.replaceAll(RegExp(r'\s+'), "".trim());

      final querySnapshot = await firestore
          .collection("users")
          .where("phoneNumber", isEqualTo: formattedPhoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking phone number existence: $e");
      return false;
    }
  }

  Future<UserModel> getUserFromFirestore(String uid) async {
    try {
      final userDoc = await firestore.collection("users").doc(uid).get();

      if (!userDoc.exists) {
        throw "User data not found";
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw "Failed to get user data";
    }
  }

  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await firestore.collection("users").doc(user.uid).set(user.toMap());
      return;
    } catch (e) {
      throw "Failed to save user data";
    }
  }
}
