//This is the node query being executed to hit the MTA API. The example is meant to demonstrate the implementation is real - live MTA data is being requested by the contract
//The code is being executed via a lambda function with an API gateway - this API endpoint is what the LDelayOracle is ultimately querying
//The lambda function is a slightly modified version of this code to conform to AWS Lambda standards
//The actual node application is at https://github.com/Denton24646/node-mta-gtfs-api so one could test the MTA API locally as well.
//Note requesting data from the MTA API needs an API key which is free but requires registering with the MTA

var GtfsRealtimeBindings = require('gtfs-realtime-bindings');
var request = require('request');
var apiKeys = require('./config');

var requestSettings = {
  method: 'GET',
  url: 'http://datamine.mta.info/mta_esi.php?key=' + apiKeys.mta + '&feed_id=2',
  encoding: null
};

var LTRAINSTATUS = 'Normal';

request(requestSettings, function (error, response, body) {
  if (!error && response.statusCode == 200) {
    var feed = GtfsRealtimeBindings.FeedMessage.decode(body);
    feed.entity.forEach(function(entity) {
        //console.log('alert: '+ entity.alert);
        //console.log(typeof entity.alert);
    });
    for (i in feed.entity) {
        if (feed.entity.alert !== undefined) {
            //console.log("Status: Delay");
            LTRAINSTATUS = 'Delayed';
            break;
        }
    }
    console.log("%s", LTRAINSTATUS);
    return LTRAINSTATUS;
  } else {
      LTRAINSTATUS = "Unknown";
      return LTRAINSTATUS;
  }
});