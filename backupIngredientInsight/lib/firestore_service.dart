import 'package:firebase_database/firebase_database.dart';

class FirestoreService {
  // Reference to the Firebase Realtime Database
  final databaseReference = FirebaseDatabase.instance.ref();

  // CREATE
  Future<void> createUser(String userID, String username, String email) async {
    try {
      await databaseReference.child("users").child(userID).set({
        'username': username,
        'email': email,
      });
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> createSkinData(String userID, String skintype, List<String> skinconcerns, bool isBreastfeeding, List<String> allergic) async {
    try {
      await databaseReference.child("skinData").child(userID).set({
        'skintype': skintype,
        'skinconcerns': skinconcerns,
        'isBreastfeeding': isBreastfeeding,
        'allergic': allergic,
      });
    } catch (e) {
      print('Error creating skin data: $e');
    }
  }

  Future<void> createProduct(String prodID, String prodName, String prodType, String scannedtext, List<String> ingredients, List<String> alert, int accuracyProductSuitability) async {
    try {
      await databaseReference.child("productData").child(prodID).set({
        'prodName': prodName,
        'prodType': prodType,
        'scannedtext': scannedtext,
        'ingredients': ingredients,
        'alert': alert,
        'accuracyProductSuitability': accuracyProductSuitability,
      });
    } catch (e) {
      print('Error creating product data: $e');
    }
  }

  // READ
  void readUser(String userID) {
    databaseReference.child("users").child(userID).once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      print('User Data: ${snapshot.value}');
    });
  }

  Future<DataSnapshot> readSkinData(String userID) async {
    try {
      DatabaseEvent event = await databaseReference.child("skinData").child(userID).once();
      return event.snapshot;
    } catch (e) {
      print('Error reading skin data: $e');
      rethrow;
    }
  }

  void readProduct(String prodID) {
    databaseReference.child("productData").child(prodID).once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      print('Product Data: ${snapshot.value}');
    });
  }

  // UPDATE
  void updateUser(String userID, Map<String, dynamic> newData) {
    databaseReference.child("users").child(userID).update(newData);
  }

  void updateSkinData(String userID, Map<String, dynamic> newData) {
    databaseReference.child("skinData").child(userID).update(newData);
  }

  void updateProduct(String prodID, Map<String, dynamic> newData) {
    databaseReference.child("productData").child(prodID).update(newData);
  }

  // DELETE
  void deleteUser(String userID) {
    databaseReference.child("users").child(userID).remove();
  }

  void deleteSkinData(String userID) {
    databaseReference.child("skinData").child(userID).remove();
  }

  void deleteProduct(String prodID) {
    databaseReference.child("productData").child(prodID).remove();
  }

  Future<void> saveUserData(Map<String, dynamic> userData, String userId) async {
    try {
      await databaseReference.child("users").child(userId).set(userData);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
}
