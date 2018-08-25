const request = require('request');
const cheerio = require('cheerio');

/*
Updated MTA API feed done directly via scarping website
Looks for subway status div element and performs regex search for L Train Delay 
If found, then train is assumed delayed, otherwise normal
Planned Work is not assumed to mean a delay
*/

var url = 'http://assistive.usablenet.com/tt/www.mta.info?un_jtt_v_status=subwayTab';

var customHeaderRequest = request.defaults({
    headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'}
})

var LTRAINSTATUS = "Normal";

customHeaderRequest.get(url, function(err, resp, body) {
    $ = cheerio.load(body);
    var resp = $('#subwayDiv').text();
    var regex = "L Subway Delays";
    result = resp.match(regex);
    //console.log(result);
    if (result === null) {
        //console.log(LTRAINSTATUS);
        return LTRAINSTATUS;
    } else {
        LTRAINSTATUS = "Delayed";
        //console.log(LTRAINSTATUS);
        return LTRAINSTATUS;
    }
})