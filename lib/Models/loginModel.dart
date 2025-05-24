// lib/Models/LoginModel.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginManager {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('Users');

  Future<bool> authenticateUser(String username, String password) async {
    try {
      final snapshot = await _userRef.orderByChild('username').equalTo(username).once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        var userKey = userData.keys.first;
        var user = userData[userKey];
        String storedHashedPassword = user['password'];

        // Verify password using bcrypt
        if (BCrypt.checkpw(password, storedHashedPassword)) {
          return true;
        }
      }
    } catch (e) {
      print('Error during authentication: $e');
    }
    return false;
  }

  // authenticating using userKey
  Future<bool> authenticateUserByKey(String userKey, String password) async {
    try {
      final snapshot = await _userRef.child(userKey).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.value as Map<String, dynamic>;
        String storedHashedPassword = userData['password'];

        // Verify password
        return BCrypt.checkpw(password, storedHashedPassword);
      }
    } catch (e) {
      print('Error during key-based authentication: $e');
    }
    return false;
  }
}
