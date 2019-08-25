#!/usr/bin/env python
# -*- coding: utf-8 -*-

from keras import layers as kl
from keras import models as km
from keras import callbacks as kc
from keras import optimizers as ko
from keras.preprocessing import image as ki
from collections import deque

REPLAY_MEMORY_SIZE = 50_000
MIN_REPLAY_MEMORY_SIZE = 1_000
MODEL_NAME = "256x2"

class Carrot:
    
    def __init__(self):

        model = kl.Dense(input_shape = (9,))
        model = kl.Dense(128, activation = "relu") (model)
        model = kl.Dense(512, activation = "sigmoid") (model)
        model = kl.Dense(256, activation = "relu") (model)
        model = kl.Dense(64, activation = "relu") (model)
        model = kl.Dense(2, activation = "linear") (model)

        self.model = km.Model(input = model.input, output = model)

        self.model.compile(loss = "mse", optimizer = ko.Adam(lr = 0.001), metrics = ["accuracy"])

        self.target = self.model
        self.target.set_weights(self.model.get_weights())