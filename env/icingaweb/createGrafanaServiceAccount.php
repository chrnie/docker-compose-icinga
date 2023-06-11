#!/usr/bin/php

<?php

// Configuration for the connection to the Grafana API
$grafanaURL = 'http://grafana:3000'; // The URL of your Grafana instance.

// Function to send a request to the API
function sendAPIRequest($url, $method = 'GET', $data = [], $username = '', $password = '') {
    global $grafanaURL;

    $curl = curl_init();
    $headers = array(
        'Content-Type: application/json'
    );

    curl_setopt($curl, CURLOPT_URL, $grafanaURL . $url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_USERPWD, $username . ':' . $password);

    if ($method != 'GET') {
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
    }

    $response = curl_exec($curl);

    if ($response === false) {
        echo 'API request error: ' . curl_error($curl) . PHP_EOL;
    } else {
        // Debug information about the API response
        $info = curl_getinfo($curl);
        echo 'API response code: ' . $info['http_code'] . PHP_EOL;
        echo 'API response: ' . $response . PHP_EOL;
    }

    curl_close($curl);

    return $response;
}

// function to create a service account
function createServiceAccount($name, $username, $password) {
    $url = '/api/serviceaccounts';
    $method = 'POST';
    $data = array(
        'name' => $name,
        'role' => 'Viewer', // The role of the service account (e.g. viewer, editor, etc.)
        'isDisabled' => false
    );

    $response = sendAPIRequest($url, $method, $data, $username, $password);
    $responseData = json_decode($response, true);

    return $responseData;
}

// Function to generate a token for a service account
function generateToken($serviceAccountID, $username, $password) {
    $url = '/api/serviceaccounts/' . $serviceAccountID . '/tokens';
    $method = 'POST';
    $data = array(
        'name' => 'read_token'.$serviceAccountID,
        'role' => 'Viewer'  // the role of the token
    );

    $response = sendAPIRequest($url, $method, $data, $username, $password);
    $responseData = json_decode($response, true);

    return $responseData;
}

// get command line parameters
if ($argc < 2) {
    echo 'Please specify the name of the service account as a command line parameter.' . PHP_EOL;
    exit;
}

$serviceAccountName = $argv[1];
$username = 'admin';
$password = 'admin';

$serviceAccount = createServiceAccount($serviceAccountName, $username, $password);

if (isset($serviceAccount['id'])) {
    $token = generateToken($serviceAccount['id'], $username, $password);

    if (isset($token['key'])) {
        echo 'Service account was successfully created.' . PHP_EOL;
        echo 'Token: ' . $token['key'] . PHP_EOL;
    } else {
        echo 'Error generating token.' . PHP_EOL;
        var_dump($token);
    }
} else {
    echo 'Error creating the service account.' . PHP_EOL;
}
?>
