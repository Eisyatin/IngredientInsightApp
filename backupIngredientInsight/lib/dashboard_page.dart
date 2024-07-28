import 'package:flutter/material.dart';
import 'package:text_recognition/result_page.dart';
import '../data/intermediate_data.dart';
import '../data/saved_prod.dart';

class DashboardPage extends StatefulWidget {
  final SurveyData surveyData;
  final List<SavedProduct> savedProducts;
  final SurveyController surveyController; // Add SurveyController

  DashboardPage({
    required this.surveyData,
    required this.savedProducts,
    required this.surveyController, // Add this line
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SavedProduct> get suitableProducts => widget.savedProducts.where((product) => product.result['prediction']['suitable'] == true).toList();
  List<SavedProduct> get unsuitableProducts => widget.savedProducts.where((product) => product.result['prediction']['suitable'] == false).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "My Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 21, 92, 42),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Suitable'),
            Tab(text: 'Not Suitable'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProfileCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(suitableProducts),
                _buildProductList(unsuitableProducts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Color.fromARGB(255, 21, 92, 42),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/ProfileEISYATIN.png'), // Replace with user's image if available
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name', // Replace with actual user name if available
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Skin Type: ${widget.surveyData.skinType}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Skin Concerns: ${widget.surveyData.skinConcerns.join(', ')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Breastfeeding: ${widget.surveyData.breastfeeding ? "Yes" : "No"}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Allergic Ingredients: ${widget.surveyData.allergicIngre.join(', ')}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Implement edit functionality here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<SavedProduct> products) {
    if (products.isEmpty) {
      return Center(child: Text('No products found.'));
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              product.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Product Type: ${product.type}\nDate: ${product.date.toLocal().toString().split(' ')[0]}'), // Replace with actual product type and date
            trailing: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: products == suitableProducts ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                products == suitableProducts ? 'Suitable' : 'Not Suitable',
                style: TextStyle(color: Colors.white),
              ),
            ),
            onTap: () {
              // Navigate back to ResultPage with saved product data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    scannedText: product.result['scannedText'],
                    metrics: product.result['metrics'],
                    ingredientCategory: product.result['ingredientCategory'],
                    prediction: product.result['prediction'],
                    trueLabels: product.result['trueLabels'],
                    surveyController: widget.surveyController, // Pass SurveyController
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
