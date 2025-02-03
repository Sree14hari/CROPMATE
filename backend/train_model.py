import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import os

def create_model():
    model = models.Sequential([
        # Input layer
        layers.Conv2D(32, (3, 3), activation='relu', input_shape=(224, 224, 3)),
        layers.MaxPooling2D((2, 2)),
        
        # Convolutional layers
        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),
        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),
        
        # Dense layers
        layers.Flatten(),
        layers.Dense(64, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(4, activation='softmax')  # 4 classes as defined in main.py
    ])
    
    return model

def train_model(train_dir, validation_dir, epochs=10):
    # Data augmentation for training
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest'
    )

    # Only rescaling for validation
    validation_datagen = ImageDataGenerator(rescale=1./255)

    # Create data generators
    train_generator = train_datagen.flow_from_directory(
        train_dir,
        target_size=(224, 224),
        batch_size=32,
        class_mode='categorical'
    )

    validation_generator = validation_datagen.flow_from_directory(
        validation_dir,
        target_size=(224, 224),
        batch_size=32,
        class_mode='categorical'
    )

    # Create and compile model
    model = create_model()
    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    # Train model
    history = model.fit(
        train_generator,
        steps_per_epoch=train_generator.samples // 32,
        epochs=epochs,
        validation_data=validation_generator,
        validation_steps=validation_generator.samples // 32
    )

    # Create model directory if it doesn't exist
    if not os.path.exists('model'):
        os.makedirs('model')

    # Save model
    model.save('model/plant_disease_model.h5')
    print("Model saved as 'model/plant_disease_model.h5'")

if __name__ == "__main__":
    # You need to specify your training and validation data directories
    print("Please organize your dataset in the following structure:")
    print("""
    data/
    ├── train/
    │   ├── healthy/
    │   ├── leaf_blight/
    │   ├── powdery_mildew/
    │   └── leaf_spot/
    └── validation/
        ├── healthy/
        ├── leaf_blight/
        ├── powdery_mildew/
        └── leaf_spot/
    """)
    
    train_dir = 'data/train'
    validation_dir = 'data/validation'
    
    if not os.path.exists(train_dir) or not os.path.exists(validation_dir):
        print("Error: Please create the data directory structure with your training images first!")
    else:
        train_model(train_dir, validation_dir)
