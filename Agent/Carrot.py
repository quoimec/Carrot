#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pymongo

from keras import models as km
from keras import layers as kl
from keras import optimizers as ko

from functools import reduce

class Carrot:
    
    # Model V1
    # - Takes 0.0 -> 1.0 input from 7 facial classes, an observation time in seconds and a session count.
    
    def __init__(self):
        
        self.cosmos = pymongo.MongoClient("mongodb://remi-mongo:tZdoiZvlNhzLlFvCfB6vApJfLNvJBDYUPoRKIn0p3ujFPbVfLnlLouQlCDKgHEaJvN5mnkzglBl5e5UjsjjLTg==@remi-mongo.documents.azure.com:10255/?ssl=true&replicaSet=globaldb")
        self.database = self.cosmos.carrot.results

        self.model = self.build(learning = 0.2)
    
    def build(self, *, learning, weights = None):
        
        input = kl.Input(shape = (15,))
        connection = kl.Dense(256, activation = "relu") (input)
        connection = kl.Dense(512, activation = "linear") (connection)
        connection = kl.Dense(256, activation = "relu") (connection)
        output = kl.Dense(2, activation = "softmax") (connection)

        model = km.Model(inputs = [input], outputs = [output])
        model.compile(optimizer = ko.Adam(lr = learning), loss = "mse")
        
        if weights != None:
            model.set_weights(weights)    
        
        return model
    
    def format(self, object):
        
        """ Data Formatter
        
            Emoji Agent Input: Vector[15]
            ->  Session Count: Float, Representing the number of games the player has played
            ->  Win Ratio: Float, Representing the proportion of the time that the Agent has won
            ->  Player One: Float, 0.0 for Human, 1.0 for Agent
            ->  Happy Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Neutral Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Disgust Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Fear Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Anger Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Surprised Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Sad Count: Float, Normalised emotions, between 0.0 and 1.0
            ->  Game Seconds: Float, The number of seconds that the game was played for before the agent needed to make a decision
            ->  Player Decision: Int, -1 for Swap, 1 for Keep and 0 if the the agent is player one
            ->  Emoji One: Int, Encoded value between 0 and 6
            ->  Emoji Two: Int, Encoded value between 0 and 6
            ->  Emoji Three: Int, Encoded value between 0 and 6
            
            Emoji Agent Actual: Vector[2]
            -> Agent Swap: Int, 1 if True, 0 if False
            -> Agent Keep: Int, 1 if True, 0 if False
            
        """
        
        total = lambda data: reduce(lambda a, b: a + b[1], data.items(), 0.0)
        normalise = lambda data: dict(map(lambda a: (a[0], a[1] / total(data)), data.items()))
        
        emojiIndex = lambda a: ["😡", "🤢", "😨", "😀", "😒", "😮", "😐"].index(a)
        emotionKeys = ["happyCount", "neutralCount", "disgustCount", "fearCount", "angerCount", "surprisedCount", "sadCount"]
        normalisedEmotions = normalise(dict(filter(lambda a: a[0] in emotionKeys, object.items())))
        
        input = [
            float(object["sessionCount"]), 
            (1 + object["humanLost"]) / (object["humanWon"] + object["humanLost"] + 2),
            0.0 if object["playerOne"] == "Human" else 1.0,
            normalisedEmotions["happyCount"],
            normalisedEmotions["neutralCount"],
            normalisedEmotions["disgustCount"],
            normalisedEmotions["fearCount"],
            normalisedEmotions["angerCount"],
            normalisedEmotions["surprisedCount"],
            normalisedEmotions["sadCount"],
            normalisedEmotions["gameSeconds"],
            0 if object["playerOne"] == "Agent" else (-1 if object["playerDecision"] == "Swap" else 1),
            emojiIndex(object["emojiOne"]),
            emojiIndex(object["emojiTwo"]),
            emojiIndex(object["emojiThree"])
        ]
        
        agentSwap = lambda carrot, decision: decision == "Keep" if carrot == "Human" else decision == "Swap"
    
        output = [
            int(agentSwap(object["carrotStart"], object["playerDecision"])),
            int(not agentSwap(object["carrotStart"], object["playerDecision"]))
        ]
        
        return input, output
    
    def train(self, epochs = 10):
        
        inputs, outputs = []
        
        for record in self.database.find({}):
            input, output = self.format(record)
            inputs.append(input)
            outputs.append(output)
        
        # inputs, outputs = list(zip(*list(map(lambda a: tuple(self.format(a)), self.database.find({})))))
        
        self.model.fit(x = inputs, y = outputs, batch_size = 1, epochs = epochs, verbose = 2)
        
        self.model.save(filepath = "carrot-model.hdf5")
        
    def test(self):
        
        inputs, outputs = list(zip(*list(map(lambda a: tuple(self.format(a)), self.database.find({})))))
        
        print(inputs[0:2])
        print(outputs[0:2])

carrot = Carrot()

# carrot.test()
carrot.train()
