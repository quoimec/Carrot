#!/usr/bin/env python
# -*- coding: utf-8 -*-

import gym
import numpy as np

environment = gym.make("MountainCar-v0")
environment.reset()

learningRate = 0.1
learningDiscount = 0.95
learningEpisodes = 25000

epsilonRate = 0.5
epsilonEnd = learningEpisodes // 2
epsilonDecay = epsilonRate / (epsilonEnd - 1)

bucketSize = 20
discreteSize = [bucketSize] * len(environment.observation_space.high)
windowSize = (environment.observation_space.high - environment.observation_space.low) / discreteSize

qTable = np.random.uniform(low = -2, high = 0, size = (discreteSize + [environment.action_space.n]))

print(discreteSize + [environment.action_space.n])

def discretiseState(passedState):
    discreteState = (passedState - environment.observation_space.low) / windowSize
    return tuple(discreteState.astype(np.int))

for eachEpisode in range(learningEpisodes):
    
    if eachEpisode % 2000 == 0:
        print("Episode {}:".format(eachEpisode))
        render = True
    else:
        render = False
        
    discreteState = discretiseState(environment.reset())

    done = False

    while not done:
        
        if np.random.random() > epsilonRate:
            action = np.argmax(qTable[discreteState])
        else:
            action = np.random.randint(0, environment.action_space.n)
            
        state, reward, done, _ = environment.step(action)
        
        if render:
            environment.render()
        
        discreteUpdate = discretiseState(state)
        
        if not done:
            qMaximum = np.max(qTable[discreteUpdate])
            qCurrent = qTable[discreteState + (action,)]
            qUpdated = (1.0 - learningRate) * qCurrent + learningRate * (reward + learningDiscount + qMaximum)
            qTable[discreteState + (action,)] = qUpdated
        elif state[0] >= environment.goal_position:
            print("Solved on episode {}".format(eachEpisode))
            qTable[discreteState + (action,)] = 0
            
        discreteState = discreteUpdate

    if epsilonEnd >= eachEpisode >= 1:
        epsilonRate -= epsilonDecay

environment.close()
