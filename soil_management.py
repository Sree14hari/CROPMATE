import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from pydantic import BaseModel
from typing import Dict, List, Optional
import joblib
import os

class SoilData(BaseModel):
    nitrogen: float
    phosphorus: float
    potassium: float
    ph: float
    rainfall: float
    temperature: float

class SoilRecommendation(BaseModel):
    soil_health: str
    recommendations: List[str]
    nutrient_status: Dict[str, str]
    suitable_crops: List[str]

# Create synthetic training data
def generate_training_data(n_samples=1000):
    np.random.seed(42)
    
    # Generate random soil parameters
    nitrogen = np.random.uniform(0, 300, n_samples)
    phosphorus = np.random.uniform(0, 30, n_samples)
    potassium = np.random.uniform(0, 300, n_samples)
    ph = np.random.uniform(4, 9, n_samples)
    rainfall = np.random.uniform(500, 2000, n_samples)
    temperature = np.random.uniform(15, 35, n_samples)
    
    # Create labels based on domain knowledge
    labels = []
    for i in range(n_samples):
        score = 0
        # Score based on optimal ranges
        if 140 <= nitrogen[i] <= 280: score += 2
        if 10 <= phosphorus[i] <= 25: score += 2
        if 150 <= potassium[i] <= 250: score += 2
        if 6.0 <= ph[i] <= 7.5: score += 2
        
        # Classify soil health
        if score >= 6:
            labels.append('Good')
        elif score >= 4:
            labels.append('Moderate')
        else:
            labels.append('Poor')
    
    # Create DataFrame
    data = pd.DataFrame({
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'ph': ph,
        'rainfall': rainfall,
        'temperature': temperature,
        'soil_health': labels
    })
    
    return data

class SoilAnalyzer:
    def __init__(self):
        self.model_path = 'soil_health_model.joblib'
        self.scaler_path = 'soil_scaler.joblib'
        
        if os.path.exists(self.model_path) and os.path.exists(self.scaler_path):
            self.model = joblib.load(self.model_path)
            self.scaler = joblib.load(self.scaler_path)
        else:
            self.train_model()
    
    def train_model(self):
        # Generate training data
        data = generate_training_data()
        
        # Prepare features and target
        X = data.drop('soil_health', axis=1)
        y = data['soil_health']
        
        # Scale features
        self.scaler = StandardScaler()
        X_scaled = self.scaler.fit_transform(X)
        
        # Train model
        self.model = RandomForestClassifier(n_estimators=100, random_state=42)
        self.model.fit(X_scaled, y)
        
        # Save model and scaler
        joblib.dump(self.model, self.model_path)
        joblib.dump(self.scaler, self.scaler_path)
    
    def get_nutrient_status(self, data: SoilData) -> Dict[str, str]:
        status = {}
        
        # Nitrogen status
        if data.nitrogen < 140:
            status["nitrogen"] = "Low"
        elif data.nitrogen > 280:
            status["nitrogen"] = "High"
        else:
            status["nitrogen"] = "Optimal"
        
        # Phosphorus status
        if data.phosphorus < 10:
            status["phosphorus"] = "Low"
        elif data.phosphorus > 25:
            status["phosphorus"] = "High"
        else:
            status["phosphorus"] = "Optimal"
        
        # Potassium status
        if data.potassium < 150:
            status["potassium"] = "Low"
        elif data.potassium > 250:
            status["potassium"] = "High"
        else:
            status["potassium"] = "Optimal"
        
        # pH status
        if data.ph < 6.0:
            status["ph"] = "Acidic"
        elif data.ph > 7.5:
            status["ph"] = "Alkaline"
        else:
            status["ph"] = "Optimal"
            
        return status
    
    def get_recommendations(self, nutrient_status: Dict[str, str]) -> List[str]:
        recommendations = []
        
        if nutrient_status["nitrogen"] == "Low":
            recommendations.append("Add nitrogen-rich fertilizers like urea or compost")
        elif nutrient_status["nitrogen"] == "High":
            recommendations.append("Reduce nitrogen fertilization")
            
        if nutrient_status["phosphorus"] == "Low":
            recommendations.append("Add phosphate fertilizers or bone meal")
        elif nutrient_status["phosphorus"] == "High":
            recommendations.append("Avoid adding phosphorus fertilizers")
            
        if nutrient_status["potassium"] == "Low":
            recommendations.append("Add potassium-rich fertilizers like potash")
        elif nutrient_status["potassium"] == "High":
            recommendations.append("Reduce potassium fertilization")
            
        if nutrient_status["ph"] == "Acidic":
            recommendations.append("Add lime to increase soil pH")
        elif nutrient_status["ph"] == "Alkaline":
            recommendations.append("Add sulfur to decrease soil pH")
            
        return recommendations
    
    def get_suitable_crops(self, data: SoilData, soil_health: str) -> List[str]:
        crops = []
        
        # Base crops on soil health and parameters
        if soil_health == 'Good':
            if 6.0 <= data.ph <= 7.0:
                if data.nitrogen >= 140:
                    crops.extend(["Tomatoes", "Leafy Greens"])
                if data.phosphorus >= 15:
                    crops.extend(["Beans", "Peas"])
                if data.potassium >= 200:
                    crops.extend(["Potatoes", "Sweet Potatoes"])
            
            if data.rainfall >= 750:
                crops.extend(["Rice", "Sugarcane"])
            else:
                crops.extend(["Wheat", "Millet"])
                
            if data.temperature >= 25:
                crops.extend(["Cotton", "Sunflower"])
            else:
                crops.extend(["Carrots", "Cabbage"])
        
        elif soil_health == 'Moderate':
            # Add crops that are more tolerant to suboptimal conditions
            crops.extend(["Maize", "Sorghum", "Groundnut"])
            
            if data.rainfall < 750:
                crops.extend(["Pearl Millet", "Chickpea"])
            
        else:  # Poor soil health
            # Add crops that can tolerate poor soil conditions
            crops.extend(["Cassava", "Sweet Potato", "Cowpea"])
        
        return list(set(crops))  # Remove duplicates
    
    def analyze_soil_health(self, data: SoilData) -> SoilRecommendation:
        # Prepare input data for prediction
        input_data = np.array([[
            data.nitrogen,
            data.phosphorus,
            data.potassium,
            data.ph,
            data.rainfall,
            data.temperature
        ]])
        
        # Scale input data
        input_scaled = self.scaler.transform(input_data)
        
        # Predict soil health
        soil_health = self.model.predict(input_scaled)[0]
        
        # Get nutrient status and recommendations
        nutrient_status = self.get_nutrient_status(data)
        recommendations = self.get_recommendations(nutrient_status)
        suitable_crops = self.get_suitable_crops(data, soil_health)
        
        return SoilRecommendation(
            soil_health=soil_health,
            recommendations=recommendations,
            nutrient_status=nutrient_status,
            suitable_crops=suitable_crops
        )

# Initialize the soil analyzer
soil_analyzer = SoilAnalyzer()

def analyze_soil_health(data: SoilData) -> SoilRecommendation:
    return soil_analyzer.analyze_soil_health(data)
