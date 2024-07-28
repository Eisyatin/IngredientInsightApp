import 'package:firebase_database/firebase_database.dart';

class SkincareProduct {
  final String name;
  final String type;
  final String ingredients;

  SkincareProduct({
    required this.name,
    required this.type,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'ingredients': ingredients,
    };
  }
}

// class SkincareProductDatabase {
//   final  fb = FirebaseDatabase.instance;

//   // void saveSkincareProduct(Map<String, dynamic> productData) {
//   //   fb.child('skincare_products').push().set(productData);
//   // }

//   Future<List<SkincareProduct>> getSavedSkincareProducts() async {
//     List<SkincareProduct> products = [];

//  // Fetch data from the database
// try {
//   DatabaseEvent event = await _database.child('skincare_products').once();
//   DataSnapshot snapshot = event.snapshot;

//   // Check if snapshot.value is not null before accessing its properties
//   if (snapshot.value != null) {
//     // Use 'as' to cast to Map<dynamic, dynamic>
//     Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    
//     // Convert the data to a List of SkincareProduct objects
//     data.forEach((key, value) {
//       var product = SkincareProduct(
//         name: value['name'],
//         type: value['type'],
//         ingredients: value['ingredients'],
//       );
//       products.add(product);
//     });
//   } else {
//     print("Snapshot value is null");
//   }
// } catch (error) {
//   print("Error fetching data: $error");
// }


//     return products;
//   }
// }
