import flask
import joblib
import pandas as pd
import numpy as np
import re
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from fuzzywuzzy import fuzz, process
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
import logging
import sklearn

# Ensure correct version of scikit-learn
REQUIRED_SKLEARN_VERSION = "1.2.2"
if sklearn.__version__ != REQUIRED_SKLEARN_VERSION:
    raise ValueError(f"Incompatible scikit-learn version: {sklearn.__version__}, required: {REQUIRED_SKLEARN_VERSION}")

app = flask.Flask(__name__)
logging.basicConfig(level=logging.DEBUG)

# Load the pre-trained model, scaler, PCA, and feature names
multi_target_svm = joblib.load(r'C:\Users\User\skincare_backend\model\multi_target_svm_model_ifipf.joblib')
scaler = joblib.load(r'C:\Users\User\skincare_backend\model\scaler_ifipf.joblib')
pca = joblib.load(r'C:\Users\User\skincare_backend\model\pca_ifipf.joblib')
feature_names = joblib.load(r'C:\Users\User\skincare_backend\model\features_ifipf.joblib')

# Load ingredient dictionary and category mappings
ingredient_dict = pd.read_excel(r'C:\Users\User\skincare_backend\data\Ingredient_Dictionary.xlsx')
ingredient_category_dict = pd.Series(ingredient_dict['Category'].values, index=ingredient_dict['Ingredient Name']).to_dict()
ingredient_alertBF_dict = pd.Series(ingredient_dict['alertBF'].values, index=ingredient_dict['Ingredient Name']).to_dict()

# Load IF-IPF values (previously calculated)
if_ipf_df = pd.read_csv(r'C:\Users\User\skincare_backend\data\if_ipf_values.csv', index_col=0)

# Define the labels (skin concerns)
labels = [
    'uneven_texture', 'elasticity', 'dullness', 'darkspot', 'pores',
    'puffiness', 'wrinkles', 'acne', 'redness'
]

def preprocess_ingredients(ingredients, ingredient_dict, ingredient_category_dict, threshold_initial=85, threshold_second=75):
    ingredients = ingredients.lower()
    ingredients = re.sub(r'[0-9.*]', '', ingredients)
    ingredient_list = [ingredient.strip().replace(' ', '_') for ingredient in ingredients.split(',')]

    def fuzzy_match_ingredient(token, threshold):
        matches = process.extractOne(token, ingredient_dict['Ingredient Name'], scorer=fuzz.token_sort_ratio)
        if matches and matches[1] >= threshold:
            matched_ingredient = matches[0]
            category = ingredient_category_dict.get(matched_ingredient, 'Unknown')
            return matched_ingredient, category, True
        else:
            return token, 'Unknown', False

    processed_ingredients = []
    ingredient_categories = []
    for token in ingredient_list:
        processed_token, category, matched = fuzzy_match_ingredient(token, threshold_initial)
        if not matched:
            processed_token, category, matched = fuzzy_match_ingredient(token, threshold_second)
        processed_ingredients.append(processed_token)
        ingredient_categories.append(category)
    return processed_ingredients, ingredient_categories

def create_feature_vector(processed_ingredients, skin_type_ohe, skin_concerns_ohe):
    # Get IF-IPF values for each processed ingredient
    if_ipf_values = [if_ipf_df.loc[ingredient].values if ingredient in if_ipf_df.index else np.zeros(if_ipf_df.shape[1]) for ingredient in processed_ingredients]
    
    if_ipf_vector = np.mean(if_ipf_values, axis=0)

    # Concatenate all features into a single vector
    feature_vector = np.concatenate([
        skin_type_ohe.values.flatten(),
        skin_concerns_ohe.values.flatten(),
        if_ipf_vector
    ])
    return feature_vector


def align_features(feature_vector, feature_names):
    feature_dict = {name: 0 for name in feature_names}  # Initialize with zeros
    for i, value in enumerate(feature_vector):
        if i < len(feature_names):
            feature_dict[feature_names[i]] = value
    aligned_vector = [feature_dict[feature] for feature in feature_names]
    return aligned_vector


@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = flask.request.json
        logging.debug(f"Received data: {data}")
        skin_type = data.get('skin_type')
        ingredients = data.get('ingredients')
        breastfeeding = data.get('breastfeeding', False)
        allergic_ingre = data.get('allergicIngre', [])
        user_skin_concerns = data.get('skin_concerns', [])
        true_labels = data.get('true_labels', None)

        # One-Hot Encode Skin Type
        skin_type_ohe = pd.get_dummies(pd.Series([skin_type]), dtype=int).reindex(columns=['combination', 'oily', 'dry', 'normal', 'sensitive'], fill_value=0)

        logging.debug(f"Skin type OHE: {skin_type_ohe}")

        # Preprocess ingredients
        processed_ingredients, ingredient_categories = preprocess_ingredients(ingredients, ingredient_dict, ingredient_category_dict)
        logging.debug(f"Processed ingredients: {processed_ingredients}")
        logging.debug(f"Ingredient categories: {ingredient_categories}")

        # Create a dictionary mapping ingredients to categories
        ingredient_category_map = dict(zip(processed_ingredients, ingredient_categories))
        logging.debug(f"Ingredient Category Map: {ingredient_category_map}")

        # Create feature vector
        feature_vector = create_feature_vector(processed_ingredients, skin_type_ohe, pd.DataFrame())  # No skin concerns in input

        # Align features with the saved feature names
        aligned_feature_vector = align_features(feature_vector, feature_names)
        logging.debug(f"Aligned feature vector shape: {len(aligned_feature_vector)}")

        # Scale and apply PCA to feature vector
        feature_vector_scaled = scaler.transform([aligned_feature_vector])
        feature_vector_pca = pca.transform(feature_vector_scaled)

        # Predict using the SVM model
        prediction = multi_target_svm.predict(feature_vector_pca)

        # Check for breastfeeding alerts
        alertBF = []
        if breastfeeding:
            for ingredient in processed_ingredients:
                if ingredient_alertBF_dict.get(ingredient, False):
                    alertBF.append(ingredient)

        # Check for allergic ingredient alerts
        alertAll = []
        if allergic_ingre:
            fragrance_detected = any(cat == 'fragrance' for cat in ingredient_categories)
            logging.debug(f"Fragrance detected: {fragrance_detected}")
            logging.debug(f"Allergic Ingredients: {allergic_ingre}")
            logging.debug(f"Ingredient categories: {ingredient_categories}")

            if fragrance_detected:
                alertAll.append('fragrance')

            # Check for paraben, sulfate, silicon in ingredient names
            for ingredient in processed_ingredients:
                logging.debug(f"Checking ingredient: {ingredient}")
                if 'paraben' in ingredient.lower():
                    logging.debug(f"Paraben detected in: {ingredient}")
                    alertAll.append('paraben')
                if 'sulfate' in ingredient.lower() or 'sulfat' in ingredient.lower():
                    logging.debug(f"Sulfate detected in: {ingredient}")
                    alertAll.append('sulfate')
                if 'silicon' in ingredient.lower():
                    logging.debug(f"Silicon detected in: {ingredient}")
                    alertAll.append('silicon')

        # Remove duplicates from alertAll
        alertAll = list(set(alertAll))
        logging.debug(f"AlertAll: {alertAll}")

        # Metrics calculation (only for evaluation purposes)
        metrics = {}
        if true_labels:
            true_labels = np.array(true_labels).reshape(1, -1)  # Ensure true_labels is in the correct shape
            metrics['f1_micro'] = f1_score(true_labels, prediction, average='micro')

        # Return prediction results
        result = {
            "predictions": {label: bool(pred) for label, pred in zip(labels, prediction[0])},
            "categories": ingredient_category_map,  # Return the ingredient-category map
            "alertBF": alertBF,
            "alertAll": alertAll,
            "metrics": metrics
        }
        logging.debug(f"Prediction result: {result}")
        return flask.jsonify(result)
    except Exception as e:
        logging.error(f"Error during prediction: {e}")
        return flask.jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
