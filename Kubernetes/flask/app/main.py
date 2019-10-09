#!/usr/bin/env python
# -*- coding: utf-8 -*-

import flask
import os
import pymongo
import json

app = flask.Flask(__name__)

@app.route("/", methods = ["GET", "POST"])
def saddleResponse():
    return "<iframe width='840' height='630' src='https://www.youtube.com/embed/kqdBD6MMciA?autoplay=1'></iframe>"
    
@app.route("/upload", methods = ["POST"])
def uploadData():
    
    client = pymongo.MongoClient(
        host = "remi-mongo.documents.azure.com",
        port = 10255,
        username = "remi-mongo",
        password = "gz7QbKTRG2rVxL6yWEFx22pwqpKjqV22s2DPlF24pBjlvh13wuAIsddPXCh4PmHsdQSkXC0U7aEO2vBbIyG2SQ==",
        ssl = True,
        replicaSet = "globaldb"
    )
    
    return flask.jsonify(flask.request.json)
    
    
if __name__ == "__main__":
    app.run(host = "0.0.0.0", port = int(os.environ["FLASK_API_PORT"]), debug = True)
