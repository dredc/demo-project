/*
 * @Author: John Cabuso  
 * @Email: dredcabuso@gmail.com
 * @Date: 2024-03-20 20:48:01 
 * @Last Modified by: Someone
 * @Last Modified time: 2024-03-20 21:26:03
 * @Description: PayAPITest.cls
 */

 @IsTest
public with sharing class PayAPITest {
    
    /**
     * Details: Test valid and successful POST Rest call
     * This method will receive business name, email address, owner name, and monthly spend
     */
    @IsTest
    static void doSuccessPost(){
        
        // Add default JSON request
        String jsonRequest = '{"name" : "Doe John 1","businessName" : "PPet buzy","businessEmail" : "pet.buzybee4@invalid.com","monthlySpending" : "$50,000 - $200,000"}';
        
        // Initialize Rest resources
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        // Add POST Rest API parameters
        request.requestURI = 'services/apexrest/CustomApi';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonRequest);

        // Add Rest Context
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        PayApi.CustomResponseWrapper postCall = PayApi.doPost();
        // Expected status code 200
        System.assertEquals(PayApi.SUCCESS_CODE, postCall.statusCode);
        Test.stopTest();
    }

    /**
     * Details: Test invalid and failed POST Rest call
     * This method will receive business name, email address, owner name, and monthly spend
     */
    @IsTest
    static void doFailedPost(){
        
        // Add default JSON request
        // Name has only 1 word
        // Business name begins with number
        String jsonRequest = '{"name" : "Doe","businessName" : "PPet buzy","1businessEmail" : "pet.buzybee4@invalid.com","monthlySpending" : "$50,000 - $200,000"}';
        
        // Initialize Rest resources
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        // Add POST Rest API parameters
        request.requestURI = 'services/apexrest/CustomApi';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonRequest);

        // Add Rest Context
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        PayApi.CustomResponseWrapper postCall = PayApi.doPost();
        // Expected status code 300
        System.assertEquals(PayApi.VALIDATION_CODE, postCall.statusCode);
        Test.stopTest();
    }

    /**
     * Details: Test blank request POST Rest call
     * This method will receive business name, email address, owner name, and monthly spend
     */
    @IsTest
    static void doBlankPost(){
        
        // Add blank JSON request
        String jsonRequest = '{}';
        
        // Initialize Rest resources
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        // Add POST Rest API parameters
        request.requestURI = 'services/apexrest/CustomApi';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonRequest);

        // Add Rest Context
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        PayApi.CustomResponseWrapper postCall = PayApi.doPost();
        // Expected status code 400
        System.assertEquals(PayApi.BLANK_DATA_CODE, postCall.statusCode);
        Test.stopTest();
    }

    /**
     * Details: Test bad request POST Rest call
     * This method will receive business name, email address, owner name, and monthly spend
     */
    @IsTest
    static void doBadRequestPost(){
        
        // Add bad JSON request
        String jsonRequest = '{"name" : xxx2,"businessName" : "PPet buzy","businessEmail" : "pet.buzybee4@invalid.com","monthlySpending" : "$50,000 - $200,000"}';
        
        // Initialize Rest resources
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        // Add POST Rest API parameters
        request.requestURI = 'services/apexrest/CustomApi';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonRequest);

        // Add Rest Context
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        PayApi.CustomResponseWrapper postCall = PayApi.doPost();
        // Expected status code 500
        System.assertEquals(PayApi.BAD_REQUEST_CODE, postCall.statusCode);
        Test.stopTest();
    }
}