exports.handler = async function (event, context) {
    console.log(JSON.stringify(event));
    var response = {
        'status': 'ok'
    }
    return response;
  };