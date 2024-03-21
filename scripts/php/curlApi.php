<?php

$param_name = trim(@$argv[1]);
$param_busName = trim(@$argv[2]);
$param_email = trim(@$argv[3]);
$param_spending = trim(@$argv[4]);

// Sample values only
// $param_name = 'Sample ';
// $param_busName = 'Curl Buziness*';
// $param_email = 'business_curl@inv.com';
// $param_spending = '1< $50,000';

// Check if all required fields are empty
if (empty($param_name) || empty($param_busName) || empty($param_email) || empty($param_spending)) {
    echo "Please enter the required values. \n";
    exit();
}

$defaultRequest = [
    'name' => $param_name,
    'businessName' => $param_busName,
    'businessEmail' => $param_email,
    'monthlySpending' => $param_spending
];

$API_AUTHORIZE_URL = 'https://test.salesforce.com/services/oauth2/authorize';
$API_TOKEN_URL = 'https://test.salesforce.com/services/oauth2/token';
$REDIRECT_URI = 'https://test.salesforce.com/oauth2/callback';

// Connected App Credentials
$CLIENT_ID = '3MVG9mywN3hwYEwkWFqfjZOZcqKcdcfHnULPjjXeNTr1OTUjoH.vscvqA4vrh7swSH394RuK5lNKOKjCZrJUl';
$CLIENT_SECRET = '49CC011A09E374395CFAF6894CC2F1FD71A2A6836695E3CD83A59B5D31A81630';
$SF_USERNAME = 'dredcabuso@gmail.com.sbx1';
$SF_PASSWORD = 'DEVS4lesf0rceACN2';

$RESPONSE_TYPE = 'code';
$GRANT_TYPE = 'authorization_code';
$PASS_TYPE = 'password';

$DEFAULT_HEADER_ARR = [
    'Content-type' => 'application/x-www-form-urlencoded'
];

// TODO: Create a curl post with user login and save session to get redirect url for authorization code
// Manual code from API_AUTHORIZE_URL
// $AUTHORIZATION_CODE = 'aPrxkhBHL8M4rLUPFNarf7IHGrkmR1NlKpZ8j7nWMEHoJnQBQaF94XuL8_UyFuw0qz7pDyAa9Q==';
/*
// START: Payload array for API_AUTHORIZE_URL
$authorizeArr = [
    'client_id' => $CLIENT_ID,
    'redirect_uri' => $REDIRECT_URI,
    'response_type' => $RESPONSE_TYPE
];

$outputAuthorize = curlPOST($API_AUTHORIZE_URL, http_build_query($authorizeArr), $DEFAULT_HEADER_ARR);

if ($outputAuthorize) {     
    $jsonResponse = json_decode($outputAuthorize);
    var_dump($jsonResponse);
}
// END: Payload array for API_AUTHORIZE_URL
*/

// START: Payload array for API_TOKEN_URL
// $tokenArr = [
//     'grant_type' => $GRANT_TYPE,
//     'code' => $AUTHORIZATION_CODE,
//     'client_id' => $CLIENT_ID,
//     'client_secret' => $CLIENT_SECRET,
//     'redirect_uri' => $REDIRECT_URI,
// ];

// USE CREDENTIALS INSTEAD OF AUTHROIZATION CODE
$passwordArr = [
    'grant_type' => $PASS_TYPE,
    'username' => $SF_USERNAME,
    'password' => $SF_PASSWORD,
    'client_id' => $CLIENT_ID,
    'client_secret' => $CLIENT_SECRET
];

// Get access token from API
$outputToken = curlPOST($API_TOKEN_URL, http_build_query($passwordArr), $DEFAULT_HEADER_ARR);

if ($outputToken) {  

    $jsonResponse = json_decode($outputToken, true);

    // Store access token
    $accessToken = trim(@$jsonResponse['access_token']);

    if (!empty($accessToken)) {

        $requestJSON = json_encode($defaultRequest);

        // Perform custom REST POST call to salesforce
        $result = doSalesforceRestPOST($requestJSON, $accessToken);
        $resultArr = @json_decode($result);
        print_r($resultArr);
    }
}
// END: Payload array for API_TOKEN_URL

/** ------------------------------------------------------------------ **/
/** GLOBAL METHOD */

// Custom Salesforce API call
function doSalesforceRestPOST($json, $token) {

    $customURL = 'https://payau--sandbox1.sandbox.my.salesforce.com/services/apexrest/CustomApi';
    $credHeader = array(
        'Content-Type: application/json',
        "Authorization: Bearer $token"
    );
    
    return curlPOST($customURL, $json, $credHeader);
}

// Standard CURL POST method
function curlPOST($url, $jsonArr, $headerArr) {

    $server_output;

    try {

        // Send POST to get access token code
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_POSTFIELDS, $jsonArr);
        curl_setopt($curl, CURLOPT_HTTPHEADER, $headerArr);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);

        // Save session
        // curl_setopt($curl, CURLOPT_COOKIEFILE, dirname(__FILE__) . '/cookie.txt');
        // curl_setopt($curl, CURLOPT_COOKIEJAR, dirname(__FILE__) . '/cookie.txt');
    
        $server_output = curl_exec($curl);
    
        // Throw error if curl fails
        if ($server_output === false) {
            throw new Exception(curl_error($curl), curl_errno($curl));
        }
    
        curl_close($curl);
    } catch (Exception $e) {
        print_r($e);
    }

    return $server_output;
}