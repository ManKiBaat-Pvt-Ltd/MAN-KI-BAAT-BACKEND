from flask import Flask, jsonify, request
from flask_pymongo import PyMongo
from bson.objectid import ObjectId


app = Flask(__name__)

app.config['MONGO_DBNAME'] = 'MANKIBAAT'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/MANKIBAAT'

mongo = PyMongo(app)

"""
flask mongoengine
"""

@app.route('/UsersMetrics/<id>', methods=['GET'])
def get_one_framework(id):
    users = mongo.db.Users

    q = users.find_one({'_id' : ObjectId(id)})

    if q:
        output = {'name' : q['name']}
        output['contact'] = {'email':q['contact']['email']}
        output['psycheMetrics'] = {'age':q['psycheMetrics']['age'],'sex':q['psycheMetrics']['age'],'anxiety':q['psycheMetrics']['anxiety'],'irritation' : q['psycheMetrics']['irritation'],'laziness' : q['psycheMetrics']['laziness'],'lowSelfWorth' : q['psycheMetrics']['lowSelfWorth'],'suicidalThoughts' : q['psycheMetrics']['suicidalThoughts'],'guilt' : q['psycheMetrics']['guilt'],'abnormalAppetite' : q['psycheMetrics']['abnormalAppetite'],'negativeThoughts' : q['psycheMetrics']['negativeThoughts'],'jealousy' : q['psycheMetrics']['jealousy'],'aggresiveness' : q['psycheMetrics']['aggresiveness'],'concentration' : q['psycheMetrics']['concentration'],'wrongDecisions' : q['psycheMetrics']['wrongDecisions']}
        output['results'] = {'type':q['results']['type'], 'stage': q['results']['stage'],'suicidalProbability': q['results']['suicidalProbability']}
    else:
        output = 'No results found'

    return jsonify(output)

@app.route('/UserResults', methods=['POST'])
def add_framework():
    userResults = mongo.db.UserResults 
    name = request.json['name']
    email = request.json['contact']['email']
    age = request.json['psycheMetrics']['age']
    sex = request.json['psycheMetrics']['sex']
    anxiety = request.json['psycheMetrics']['anxiety']
    irritation = request.json['psycheMetrics']['irritation']
    laziness = request.json['psycheMetrics']['laziness']
    lowSelfWorth= request.json['psycheMetrics']['lowSelfWorth']
    suicidalThoughts = request.json['psycheMetrics']['suicidalThoughts']
    guilt = request.json['psycheMetrics']['guilt']
    abnormalAppetite = request.json['psycheMetrics']['abnormalAppetite']
    negativeThoughts = request.json['psycheMetrics']['negativeThoughts']
    jealousy = request.json['psycheMetrics']['jealousy']
    aggresiveness = request.json['psycheMetrics']['aggresiveness']
    concentration = request.json['psycheMetrics']['concentration']
    wrongDecisions = request.json['psycheMetrics']['wrongDecisions']
    typeofdep = request.json['results']['type']
    stage = request.json['results']['stage']
    suicidalProbability = request.json['results']['suicidalProbability']
    userResults.insert_one({'name' : name, 'contact' :{ 'email' : email},'psycheMetrics':{'age':age,'sex':age,'anxiety':anxiety,'irritation' :irritation,'laziness' : laziness,'lowSelfWorth' : lowSelfWorth,'suicidalThoughts' : suicidalThoughts,'guilt' : guilt,'abnormalAppetite' : abnormalAppetite,'negativeThoughts' : negativeThoughts,'jealousy' : jealousy,'aggresiveness' : aggresiveness,'concentration' : concentration,'wrongDecisions' : wrongDecisions }, 'results':{'type':typeofdep, 'stage': stage,'suicidalProbability': suicidalProbability}})
    return "success"

if __name__ == '__main__':
    app.run(debug=True)
