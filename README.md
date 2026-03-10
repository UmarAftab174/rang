# RANG — AI Color Classifier

RANG is an on-device AI mobile application that classifies plastic objects by color in real-time using a custom-trained Convolutional Neural Network (CNN), built for the KHILONA toy factory's automated conveyor belt sorting system.

---

## Problem Statement

KHILONA factory receives plastic objects and routes them to conveyor belts based on color:

| Color     | Conveyor Belt |
| --------- | ------------- |
| 🔵 Blue   | Belt A        |
| 🟡 Yellow | Belt B        |
| 🟣 Purple | Belt C        |

---

## Solution

A CNN trained from scratch on a self-collected dataset of 312 images, exported to TensorFlow Lite, and deployed inside a Flutter Android app for live on-device camera inference — no server required.

---

## Project Structure

```
rang/
│
├── model/                          # Python training pipeline
│   ├── dataset/
│   │   ├── train/
│   │   │   ├── blue/               # 84 images
│   │   │   ├── purple/             # 95 images
│   │   │   └── yellow/             # 69 images
│   │   ├── val/
│   │   │   ├── blue/               # 22 images
│   │   │   ├── purple/             # 24 images
│   │   │   └── yellow/             # 18 images
│   │   └── test/                   # 18 images for live demo testing
│   ├── training.ipynb              # Full training notebook (17 cells)
│   ├── requirements.txt            # Python dependencies
│   └── saved_model/
│       ├── conveyor_model.h5       # Keras model
│       ├── conveyor_model.tflite   # TFLite model for Flutter
│       ├── training_curves.png     # Accuracy & loss plots
│       ├── confusion_matrix.png    # Per-class confusion matrix
│       ├── sample_images.png       # Dataset preview
│       └── test_predictions.png   # Test set prediction grid
│
├── app/                            # Flutter Android app
│   ├── lib/
│   │   ├── main.dart               # App entry point, Material 3 theme
│   │   ├── screens/
│   │   │   ├── splash_screen.dart  # Animated logo screen
│   │   │   └── main_screen.dart    # Live camera + inference screen
│   │   └── services/
│   │       └── classifier_service.dart  # TFLite wrapper
│   ├── asset/
│   │   ├── RANG.png                # App logo
│   │   └── conveyor_model.tflite  # Copied from saved_model/
│   └── pubspec.yaml
│
└── README.md
```

---

## Dataset

| Split     | Blue    | Purple  | Yellow | Total   |
| --------- | ------- | ------- | ------ | ------- |
| Train     | 84      | 95      | 69     | 248     |
| Val       | 22      | 24      | 18     | 64      |
| Test      | —       | —       | —      | 18      |
| **Total** | **106** | **119** | **87** | **312** |

- 80% self-collected datasets used
- Photos taken with mobile phones of real colored objects
- Varied lighting, angles, and backgrounds
- No data augmentation applied

---

## Model Architecture

Custom CNN — trained from scratch, no pretrained weights, no transfer learning.

```
Input (256×256×3)
      ↓
Conv2D(16, 3×3, relu) → MaxPool(2×2)
      ↓
Conv2D(32, 3×3, relu) → MaxPool(2×2)
      ↓
Conv2D(64, 3×3, relu) → MaxPool(2×2)
      ↓
GlobalAveragePooling2D
      ↓
Dropout(0.5)
      ↓
Dense(64, relu)
      ↓
Dense(3, softmax)
```

| Hyperparameter          | Value                    |
| ----------------------- | ------------------------ |
| Input size              | 256 × 256 × 3            |
| Optimizer               | Adam                     |
| Learning rate           | 0.003                    |
| Loss function           | Categorical Crossentropy |
| Max epochs              | 100                      |
| Batch size              | 32                       |
| Early stopping patience | 10 epochs                |
| LR reduction patience   | 5 epochs                 |
| LR reduction factor     | 0.5                      |

---

## Training Notebook — Cell Guide

| Cell | Description                                            |
| ---- | ------------------------------------------------------ |
| 1    | Install dependencies                                   |
| 2    | Import libraries                                       |
| 3    | Configuration (paths, hyperparameters)                 |
| 4    | Google Drive mount (Colab only)                        |
| 5    | Verify dataset structure + image counts                |
| 6    | Preview sample images from each class                  |
| 7    | Load train and val generators (no augmentation)        |
| 8    | Count exact train/val images per class                 |
| 9    | Build CNN model                                        |
| 10   | Compile model                                          |
| 11   | Configure callbacks                                    |
| 12   | Train model                                            |
| 13   | Plot accuracy & loss curves                            |
| 14   | Evaluate — validation accuracy + classification report |
| 15   | Confusion matrix                                       |
| 16   | Test predictions on 18 test images (grid view)         |
| 17   | Export to TFLite                                       |
| 18   | Final summary                                          |

---

## Setup & Training

### 1. Create virtual environment

```bash
python -m venv tf-env
source tf-env/bin/activate        # Linux/Mac
tf-env\Scripts\activate           # Windows
```

### 2. Install dependencies

```bash
cd model
pip install -r requirements.txt
```

### 3. Prepare dataset

```
model/dataset/
├── train/
│   ├── blue/
│   ├── purple/
│   └── yellow/
└── val/
    ├── blue/
    ├── purple/
    └── yellow/
```

### 4. Run notebook

Open `training.ipynb` in Jupyter or VS Code and run all cells in order.

```bash
jupyter notebook training.ipynb
```

### 5. Output files

After training completes, `saved_model/` will contain:

- `conveyor_model.h5` — full Keras model
- `conveyor_model.tflite` — mobile-optimized model
- `training_curves.png` — accuracy/loss plots
- `confusion_matrix.png` — per-class results

---

## Mobile App

### Tech Stack

| Component   | Technology                 |
| ----------- | -------------------------- |
| Framework   | Flutter (Dart)             |
| Inference   | tflite_flutter (on-device) |
| Camera      | camera package             |
| Min Android | SDK 21 (Android 5.0)       |

### App Flow

```
Splash Screen (3s animated logo)
        ↓
Main Screen (full-screen camera)
        ↓
User taps scan button
        ↓
Live inference every 800ms
        ↓
Color + Belt + Confidence shown on screen
```

### Deploy to Android

```bash
cd app

# Install dependencies
flutter pub get

# Copy trained model
cp ../model/saved_model/conveyor_model.tflite asset/

# Build debug APK (for testing)
flutter build apk --debug

# Build release APK (for submission/demo)
flutter build apk --release
```

APK location:

```
app/build/app/outputs/flutter-apk/app-release.apk
```

---

## Constraints Followed

- ✅ No pretrained models (no ImageNet, no transfer learning)
- ✅ No if/else classification logic
- ✅ Dataset collected by team members (not from internet)
- ✅ CNN trained entirely from scratch
- ✅ On-device inference (no internet/server required)
- ✅ Submitted as PDF on LMS

---

## Submission

- **Deadline:** 15-03-2026
- **Course:** AIC-401 Deep Learning
- **University:** Bahria University
- **Semester:** 06 — Spring 2026
- **Submission format:** PDF on LMS
