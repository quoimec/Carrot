#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import getch
from reprint import output

os.chdir("/Users/Charlie/Projects/UTS/Capstones/Carrot/") 

dockerFiles = [
    {"queued": False, "name": "Flask", "tag": "remischacher/carrot-flask", "path": "flask/Dockerfile", "yaml": "flask/flask.yaml"},
    {"queued": False, "name": "Mongo", "tag": "remischacher/carrot-mongo", "path": "mongo/Dockerfile", "yaml": "mongo/mongo.yaml"}
]

userInput = None

with output(initial_len = 3 + len(dockerFiles) + 1, interval = 0) as output_lines:
    
    output_lines[0] = "\n"
    output_lines[1] = "Key in the ID for each of the services you want to create then hit RETURN"
    output_lines[2] = "\n"
    output_lines[-1] = "\n" 
    
    while userInput != "\n":
        
        try:
            dockerFiles[int(userInput) - 1]["queued"] = not dockerFiles[int(userInput) - 1]["queued"]
        except:
            pass
        
        for i in range(len(dockerFiles)):
            
            output_lines[3 + i] = " ({}) - {} {}".format( i + 1, "[x]" if dockerFiles[i]["queued"] else "[ ]", dockerFiles[i]["name"])
          
        userInput = getch.getch()

buildJob = list(filter(lambda a: a["queued"], dockerFiles))

if len(buildJob) == 0:
    print("No items selected.")
    sys.exit()
    
print("Queued docker build for the following tasks: {}\n".format(", ".join(list(map(lambda a: a["name"], buildJob)))))

for eachUpdate in buildJob:

    # To silence terminal output:
    # > /dev/null 2>&1
    
    # Check for better processing of post command parsing:
    # https://stackoverflow.com/questions/33985863/hiding-console-output-produced-by-os-system

    os.system("docker build -f {} -t {} .;".format(eachUpdate["path"], eachUpdate["tag"]))
    os.system("docker push {};".format(eachUpdate["tag"])) 

    if "yaml" in eachUpdate:
        os.system("kubectl delete -f {};".format(eachUpdate["yaml"]))
        os.system("kubectl create -f {};".format(eachUpdate["yaml"])) 








