from fastapi import HTTPException
from pydantic import BaseModel
import numpy as np
from typing import List, Optional
import requests
from datetime import datetime

class LocationData(BaseModel):
    latitude: float
    longitude: float

class WeatherData(BaseModel):
    temperature: float
    humidity: float
    rainfall: float
    description: str

class CropPredictionResponse(BaseModel):
    weather: WeatherData
    suitable_crops: List[str]
    season: str
    confidence_scores: dict

# OpenWeatherMap API configuration
WEATHER_API_KEY = "d112bb7fbb737d73b1fdf2574fe391eb"  # Add your OpenWeatherMap API key here
WEATHER_API_URL = "https://api.openweathermap.org/data/2.5/weather"

def get_season(month: int, temperature: float) -> str:
    if 3 <= month <= 5:
        return "Spring"
    elif 6 <= month <= 8:
        return "Summer"
    elif 9 <= month <= 11:
        return "Fall"
    else:
        return "Winter"

def get_weather_data(lat: float, lon: float) -> WeatherData:
    try:
        params = {
            "lat": lat,
            "lon": lon,
            "appid": WEATHER_API_KEY,
            "units": "metric"  # For Celsius
        }
        
        response = requests.get(WEATHER_API_URL, params=params)
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch weather data")
        
        data = response.json()
        
        # Extract relevant weather information
        temperature = data["main"]["temp"]
        humidity = data["main"]["humidity"]
        # Convert rainfall from mm/3h to approximate daily mm
        rainfall = data.get("rain", {}).get("3h", 0) * 8  # Approximate daily rainfall
        description = data["weather"][0]["description"]
        
        return WeatherData(
            temperature=temperature,
            humidity=humidity,
            rainfall=rainfall,
            description=description
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Weather API error: {str(e)}")

def predict_suitable_crops(weather: WeatherData, current_month: int) -> CropPredictionResponse:
    season = get_season(current_month, weather.temperature)
    suitable_crops = []
    confidence_scores = {}
    
    # Define crop suitability based on weather conditions and season
    crop_conditions = {
        "Rice": {
            "temp_range": (20, 35),
            "rainfall_range": (150, 300),
            "humidity_range": (60, 90),
            "seasons": ["Summer", "Fall"]
        },
        "Wheat": {
            "temp_range": (15, 25),
            "rainfall_range": (50, 100),
            "humidity_range": (40, 70),
            "seasons": ["Winter", "Spring"]
        },
        "Corn": {
            "temp_range": (18, 32),
            "rainfall_range": (50, 200),
            "humidity_range": (50, 80),
            "seasons": ["Spring", "Summer"]
        },
        "Cotton": {
            "temp_range": (21, 35),
            "rainfall_range": (50, 150),
            "humidity_range": (40, 70),
            "seasons": ["Summer"]
        },
        "Sugarcane": {
            "temp_range": (20, 35),
            "rainfall_range": (150, 300),
            "humidity_range": (60, 90),
            "seasons": ["Spring", "Summer"]
        },
        "Tomatoes": {
            "temp_range": (15, 30),
            "rainfall_range": (40, 100),
            "humidity_range": (50, 80),
            "seasons": ["Spring", "Summer"]
        },
        "Potatoes": {
            "temp_range": (15, 25),
            "rainfall_range": (30, 100),
            "humidity_range": (40, 75),
            "seasons": ["Spring", "Fall"]
        },
        "Onions": {
            "temp_range": (12, 28),
            "rainfall_range": (30, 100),
            "humidity_range": (40, 70),
            "seasons": ["Winter", "Spring"]
        }
    }
    
    for crop, conditions in crop_conditions.items():
        score = 0
        max_score = 4  # Temperature, rainfall, humidity, and season
        
        # Check temperature suitability
        if conditions["temp_range"][0] <= weather.temperature <= conditions["temp_range"][1]:
            score += 1
        
        # Check rainfall suitability
        if conditions["rainfall_range"][0] <= weather.rainfall <= conditions["rainfall_range"][1]:
            score += 1
        
        # Check humidity suitability
        if conditions["humidity_range"][0] <= weather.humidity <= conditions["humidity_range"][1]:
            score += 1
        
        # Check season suitability
        if season in conditions["seasons"]:
            score += 1
        
        # Calculate confidence score as percentage
        confidence = (score / max_score) * 100
        
        if confidence >= 50:  # Only include crops with >50% confidence
            suitable_crops.append(crop)
            confidence_scores[crop] = round(confidence, 2)
    
    # Sort crops by confidence score
    suitable_crops.sort(key=lambda x: confidence_scores[x], reverse=True)
    
    return CropPredictionResponse(
        weather=weather,
        suitable_crops=suitable_crops,
        season=season,
        confidence_scores=confidence_scores
    )
