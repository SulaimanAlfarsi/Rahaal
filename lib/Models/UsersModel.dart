// lib/Models/UsersModel.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:bcrypt/bcrypt.dart';

class Users {
  final String username;
  final String email;
  final String password;
  final String role;

  Users(this.username, this.email, this.password, {this.role = "user"});

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email.toLowerCase(),
    'password': password,
    'role': role,
  };

  static final DatabaseReference _userRef =
  FirebaseDatabase.instance.ref().child('Users');

  // Method to get userKey by username
  static Future<String?> getUserKeyByUsername(String username) async {
    final snapshot =
    await _userRef.orderByChild('username').equalTo(username).once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> userData =
      snapshot.snapshot.value as Map<dynamic, dynamic>;
      return userData.keys.first;
    }
    return null;
  }

  // Method to get user role by username
  static Future<String?> getRoleByUsername(String username) async {
    final snapshot =
    await _userRef.orderByChild('username').equalTo(username).once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> userData =
      snapshot.snapshot.value as Map<dynamic, dynamic>;
      var user = userData.values.first;
      return user['role'] ?? "user";
    }
    return null;
  }

  // Get user details by username
  static Future<Users?> getUserDetails(String username) async {
    final snapshot =
    await _userRef.orderByChild('username').equalTo(username).once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> userData =
      snapshot.snapshot.value as Map<dynamic, dynamic>;
      var user = userData.values.first;
      return Users(
        user['username'],
        user['email'],
        user['password'],
        role: user['role'] ?? "user",
      );
    }
    return null;
  }

  // Validate username
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) return "Username cannot be empty";
    if (name.length < 4) return "Invalid username, must be at least 4 characters";
    if (RegExp(r'^\d+$').hasMatch(name)) return "Username cannot be only numbers";
    if (!RegExp(r'[A-Za-z]').hasMatch(name)) return "Username must contain a letter";
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(name)) {
      return "Username can only contain letters and numbers";
    }
    return null;
  }

  // Validate email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return "Email cannot be empty";
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      return "Invalid Email";
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return "Password cannot be empty";
    if (!RegExp(r'^(?=.*[A-Z]).{7,}$').hasMatch(password)) {
      return "Password must be at least 7 characters and contain an \n uppercase letter";
    }
    return null;
  }

  // Check if username exists
  static Future<bool> usernameExists(String username) async {
    final snapshot =
    await _userRef.orderByChild('username').equalTo(username).once();
    return snapshot.snapshot.value != null;
  }

  // Check if email exists
  static Future<bool> emailExists(String email) async {
    final snapshot =
    await _userRef.orderByChild('email').equalTo(email.toLowerCase()).once();
    return snapshot.snapshot.value != null;
  }

  // Hash password using bcrypt
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  // Verify password using bcrypt
  static bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }

  // Sign up new user
  static Future<String?> signUpUser(
      String username, String email, String password, {String role = "user"}) async {
    // Validate inputs
    String? usernameValidation = validateName(username);
    if (usernameValidation != null) return usernameValidation;

    String? emailValidation = validateEmail(email);
    if (emailValidation != null) return emailValidation;

    String? passwordValidation = validatePassword(password);
    if (passwordValidation != null) return passwordValidation;

    // Check if username and email exist
    if (await usernameExists(username)) return "Username already exists";
    if (await emailExists(email)) return "Email already exists";

    // If validations pass, hash password and save user
    String hashedPassword = hashPassword(password);
    Users newUser = Users(username, email.toLowerCase(), hashedPassword, role: role);

    await _userRef.push().set(newUser.toJson());
    return null; // Success
  }

  // Update password by email
  static Future<bool> updatePasswordByEmail(String email, String newPassword) async {
    try {
      final snapshot =
      await _userRef.orderByChild('email').equalTo(email.toLowerCase()).once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData =
        snapshot.snapshot.value as Map<dynamic, dynamic>;
        var userKey = userData.keys.first;

        String hashedPassword = hashPassword(newPassword);
        await _userRef.child(userKey).update({'password': hashedPassword});
        return true;
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
    return false;
  }

  // Update password by username
  static Future<bool> updatePassword(String username, String newPassword) async {
    try {
      final snapshot =
      await _userRef.orderByChild('username').equalTo(username).once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData =
        snapshot.snapshot.value as Map<dynamic, dynamic>;
        var userKey = userData.keys.first;

        String hashedPassword = hashPassword(newPassword);
        await _userRef.child(userKey).update({'password': hashedPassword});
        return true;
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
    return false;
  }

  // Get email by username
  static Future<String?> getEmailByUsername(String username) async {
    final snapshot =
    await _userRef.orderByChild('username').equalTo(username).once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> userData =
      snapshot.snapshot.value as Map<dynamic, dynamic>;
      var user = userData.values.first;
      return user['email'];
    }
    return null;
  }

  // to get email by userKey
  static Future<String?> getEmailByUserKey(String userKey) async {
    try {
      final snapshot = await _userRef.child(userKey).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.value as Map<String, dynamic>;
        return userData['email'];
      }
    } catch (e) {
      print('Error fetching email by userKey: $e');
    }
    return null;
  }

  // to update password by userKey
  static Future<bool> updatePasswordByKey(String userKey, String newPassword) async {
    try {
      String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await _userRef.child(userKey).update({'password': hashedPassword});
      return true;
    } catch (e) {
      print('Failed to update password: $e');
    }
    return false;
  }
}
