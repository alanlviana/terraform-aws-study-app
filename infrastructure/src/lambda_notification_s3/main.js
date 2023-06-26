module.exports.handler = async (event, context, callback) => {
	console.log(JSON.stringify(event));
    var response = {
        'status': 'ok'
    }
	callback(null, response);
};