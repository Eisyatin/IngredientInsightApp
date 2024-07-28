void updateSkinConcernColumns(List<Map<String, dynamic>> data, List<String> allConcerns) {
  // Add binary columns for each concern
  for (var item in data) {
    for (var concern in allConcerns) {
      item[concern] = item['Skin Concern Suitability'].contains(concern) ? 1 : 0;
    }
  }

  // Print the updated data
  for (var item in data) {
    print(item);
  }
}

void main() {
  // List of all concerns
  List<String> allConcerns = ['dullness', 'acne', 'puffiness', 'elasticity', 'pores', 'darkspot', 'redness', 'uneven_texture', 'wrinkles'];

  // Example skin concern suitability data
  List<Map<String, dynamic>> data = [
    {'Skin Concern Suitability': ['dullness', 'acne']},
    {'Skin Concern Suitability': ['puffiness', 'elasticity']},
    {'Skin Concern Suitability': ['pores', 'darkspot', 'redness']}
  ];

  // Update data with binary columns
  updateSkinConcernColumns(data, allConcerns);
}
