import 'dart:developer';
import 'package:chatup/data/models/user_model.dart';
import 'package:chatup/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
    try {
      bool hasPermission = await requestContactsPermission();
      if (!hasPermission) {
        log("Contacts permission denied");
        return [];
      }

      //   Get device contacts with phone number
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      //   Extract phone numbers and normalize them (if +91 12345.. then 12345...)
      final phoneNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map(
            (contact) => {
              "name": contact.displayName,
              "phoneNumber": contact.phones.first.number.replaceAll(
                RegExp(r'[^\d+]'),
                '',
              ),
              "photo": contact.photo,
            },
          )
          .toList();

      //   Get All users from Firestore
      final usersSnapshot = await firestore.collection("users").get();
      final registeredUsers = usersSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      //   Match the contacts with registered users
      final matchedContacts = phoneNumbers
          .where((contacts) {
            String phoneNumber = contacts["phoneNumber"].toString();

            // Remove +91 from the phone number
            if (phoneNumber.startsWith("+91")) {
              phoneNumber = phoneNumber.substring(3);
            }

            return registeredUsers.any(
              (user) =>
                  user.phoneNumber == phoneNumber && user.uid != currentUserId,
            );
          })
          .map((contact) {
            String phoneNumber = contact["phoneNumber"].toString();

            // Remove +91 from the phone number
            if (phoneNumber.startsWith("+91")) {
              phoneNumber = phoneNumber.substring(3);
            }

            final registeredUser = registeredUsers.firstWhere(
              (user) => user.phoneNumber == phoneNumber,
            );

            return {
              "id": registeredUser.uid,
              "name": contact["name"],
              "phoneNumber": contact["phoneNumber"],
            };
          })
          .toList();

      return matchedContacts;
    } catch (e) {
      log("Error in getting registered contacts");
      return [];
    }
  }
}
