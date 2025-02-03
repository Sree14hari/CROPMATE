from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import tensorflow as tf
from PIL import Image
import io
import base64
import uvicorn
from pydantic import BaseModel
from typing import Optional
from soil_management import SoilData, analyze_soil_health
from crop_prediction import LocationData, predict_suitable_crops, get_weather_data
from datetime import datetime

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://crop-mate-sreehari.web.app"],  # Firebase hosting URL
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Disease classes
CLASSES = [
    'Healthy',
    'Leaf Blight',
    'Powdery Mildew',
    'Leaf Spot'
]

# Using dummy predictions for now
def get_dummy_prediction():
    """Return a dummy prediction for testing."""
    # Simulate confidence scores for each class
    confidences = {
        'Healthy': 0.7,
        'Leaf Blight': 0.1,
        'Powdery Mildew': 0.1,
        'Leaf Spot': 0.1
    }
    
    # Return the prediction with highest confidence
    predicted_class = max(confidences, key=confidences.get)
    return {
        'disease': predicted_class,
        'confidence': confidences[predicted_class],
        'all_confidences': confidences
    }

class ImageRequest(BaseModel):
    image: str

def get_recommendations(disease: str) -> str:
    """Get recommendations based on detected disease."""
    recommendations = {
        'Leaf Blight': '''
• Apply copper-based fungicides
• Improve air circulation
• Remove infected leaves
• Water at soil level to avoid wet leaves''',
        'Powdery Mildew': '''
• Apply sulfur-based fungicides
• Increase plant spacing
• Avoid overhead watering
• Ensure good air circulation''',
        'Leaf Spot': '''
• Remove infected leaves
• Apply appropriate fungicide
• Maintain proper spacing
• Avoid overwatering''',
        'Healthy': '''
• Continue current care practices
• Monitor regularly for any changes
• Maintain good air circulation
• Follow regular fertilization schedule'''
    }
    
    return recommendations.get(disease, '''
• Monitor the plant closely
• Ensure proper watering
• Maintain good air circulation
• Consider consulting a local agricultural expert''')

@app.post("/predict")
async def predict_base64(request: ImageRequest):
    """Endpoint for plant disease prediction."""
    try:
        # Decode base64 image
        image_data = base64.b64decode(request.image.split(',')[1])
        image = Image.open(io.BytesIO(image_data))
        
        # For now, we'll use dummy predictions
        prediction = get_dummy_prediction()
        
        # Get recommendations for the predicted disease
        recommendations = get_recommendations(prediction['disease'])
        
        return {
            "success": True,
            "prediction": prediction,
            "recommendations": recommendations
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze_soil")
async def analyze_soil(data: SoilData):
    try:
        result = analyze_soil_health(data)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/predict_crops")
async def predict_crops(location: LocationData):
    try:
        # Get current weather data
        weather_data = get_weather_data(location.latitude, location.longitude)
        
        # Get current month
        current_month = datetime.now().month
        
        # Predict suitable crops
        prediction = predict_suitable_crops(weather_data, current_month)
        return prediction
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "model_loaded": False
    }

if __name__ == "__main__":
    print("Starting Plant Disease Detection API...")
    print(f"Model status: {'Loaded' if False else 'Running with dummy predictions'}")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
