import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_recognition/scanPage.dart';
import 'firebase_options.dart';// Replace with the correct path
import 'package:text_recognition/data/skincare_prod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';




class SavedProductsPage extends StatefulWidget {
  @override
  _SavedProductsPageState createState() => _SavedProductsPageState();
}

class _SavedProductsPageState extends State<SavedProductsPage> {
  final fb = FirebaseDatabase.instance;
  TextEditingController productNameController = TextEditingController();
  TextEditingController productTypeController = TextEditingController();
  TextEditingController scannedTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ref = fb.ref().child('skincareProd');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 21, 92, 42),
        onPressed: () {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => //ScanPage(),
          //   ),
          // );
        },
        child: Icon(
          Icons.add, color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Product List',
          style: TextStyle(
            fontSize: 30, color: Colors.white
          ),
        ),
        backgroundColor: Color.fromARGB(255, 21, 92, 42),
      ),
      body: FirebaseAnimatedList(
        query: ref,
        shrinkWrap: true,
        itemBuilder: (context, snapshot, animation, index) {
          var productData = snapshot.value as Map<dynamic, dynamic>?;

          if (productData != null) {
            String prodName= productData['prodName'] ?? '';
            String prodType = productData['prodType'] ?? '';
            String scannedText = productData['scannedText'] ?? '';

            return GestureDetector(
              onTap: () {
                setState(() {
                  productNameController.text = prodName;
                  productTypeController.text = prodType;
                  scannedTextController.text = scannedText;
                });

                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: TextField(
                      controller: productNameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Product Name',
                      ),
                    ),
                    content: TextField(
                      controller: productTypeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Product Type',
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        color: Color.fromARGB(255, 21, 92, 42),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await updateProduct(snapshot.key!);
                          Navigator.of(ctx).pop();
                        },
                        color: Color.fromARGB(255, 21, 92, 42),
                        child: Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.indigo[100],
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                      onPressed: () {
                        ref.child(snapshot.key!).remove();
                      },
                    ),
                    title: Text(
                      prodName,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      prodType,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container(); // Placeholder for empty or corrupted data
          }
        },
      ),
    );
  }

  Future<void> updateProduct(String key) async {
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("skincareProd/$key");

    await ref1.update({
      "prodName": productNameController.text,
      "prodType": productTypeController.text,
    });

    productNameController.clear();
    productTypeController.clear();
  }
}



