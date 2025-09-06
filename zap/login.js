function authenticate(helper, paramsValues, credentials) {
    var data = JSON.stringify({
        username: credentials.getParam('username'),
        password: credentials.getParam('password')
    });
    var msg = helper.prepareMessage();
    msg.setRequestHeader("POST " + paramsValues.get('loginUrl') + " HTTP/1.1");
    msg.getRequestHeader().setHeader('Content-Type', 'application/json');
    msg.setRequestBody(data);
    helper.sendAndReceive(msg);
    var token = JSON.parse(msg.getResponseBody().toString()).token;
    return token;
}
