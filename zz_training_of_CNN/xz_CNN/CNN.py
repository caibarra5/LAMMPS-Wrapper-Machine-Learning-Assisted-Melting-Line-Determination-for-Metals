#!/usr/bin/env python3

import sys

import tensorflow as tf
from tensorflow.keras.models import Sequential,model_from_json
from tensorflow.keras.layers import Dense, Dropout, Activation, Flatten, Conv2D, MaxPooling2D


# load json and create model
json_file = open('CNN_model.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
loaded_model = model_from_json(loaded_model_json)
# load weights into new model
loaded_model.load_weights("CNN_model.h5")

import cv2

CATEGORIES = ["yy_not_melting_graphs","yz_melting_graphs"]

def prepare(filepath):
    IMG_SIZE = 300
    img_array = cv2.imread(filepath, cv2.IMREAD_GRAYSCALE)
    new_array = cv2.resize(img_array, (IMG_SIZE, IMG_SIZE))
    return new_array.reshape(-1, IMG_SIZE, IMG_SIZE, 1)

prediction = loaded_model.predict([prepare(sys.argv[1])])

print(sys.argv[1])

print(int(prediction[0][0]))
print(CATEGORIES[int(prediction[0][0])])
