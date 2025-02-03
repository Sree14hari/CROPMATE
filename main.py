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
    allow_origins=["https://your-firebase-hosting-url.com"],  # Replace with your Firebase hosting URL in production
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Load the model (replace with your model path)
try:
    model = tf.keras.models.load_model('model/plant_disease_model.h5')
except:
    print("Warning: Running without model - using dummy predictions for testing")
    model = None

# Disease classes
CLASSES = [
    'Healthy',
    'Leaf Blight',
    'Powdery Mildew',
    'Leaf Spot'
]

class ImageRequest(BaseModel):
    image: str

def preprocess_image(image_data: Image.Image) -> np.ndarray:
    """Preprocess the image for model prediction."""
    try:
        # Convert to RGB if needed
        if image_data.mode != 'RGB':
            image_data = image_data.convert('RGB')
        
        # Resize to model input size
        image_data = image_data.resize((224, 224))
        
        # Convert to array and normalize
        img_array = np.array(image_data)
        img_array = img_array.astype('float32') / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        
        return img_array
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error preprocessing image: {str(e)}")

def get_dummy_prediction() -> tuple[str, float]:
    """Return dummy prediction for testing without model."""
    import random
    class_idx = random.randint(0, len(CLASSES)-1)
    confidence = random.uniform(0.7, 1.0)
    return CLASSES[class_idx], confidence

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

@app.post("/predict_base64")
async def predict_base64(request: ImageRequest):
    try:
        # Decode base64 image
        try:
            image_data = base64.b64decode(request.image)
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid base64 image data: {str(e)}")

        # Open image
        try:
            image = Image.open(io.BytesIO(image_data))
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Error opening image: {str(e)}")

        if model is None:
            # Use dummy prediction if no model is loaded
            disease, confidence = get_dummy_prediction()
            print(f"Using dummy prediction: {disease} ({confidence:.2%})")
        else:
            # Preprocess image and make prediction
            processed_image = preprocess_image(image)
            predictions = model.predict(processed_image)[0]
            predicted_class = np.argmax(predictions)
            confidence = float(predictions[predicted_class])
            disease = CLASSES[predicted_class]

        # Get recommendations
        recommendations = get_recommendations(disease)
        
        return {
            "success": True,
            "disease": disease,
            "confidence": confidence,
            "recommendations": recommendations
        }

    except HTTPException as he:
        return {
            "success": False,
            "error": he.detail
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Unexpected error: {str(e)}"
        }

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
        "model_loaded": model is not None
    }

if __name__ == "__main__":
    print("Starting Plant Disease Detection API...")
    print(f"Model status: {'Loaded' if model is not None else 'Running with dummy predictions'}")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
