/*
 * @Author: John Cabuso 
 * @Email: dredcabuso@gmail.com
 * @Date: 2024-03-20 15:31:38 
 * @Last Modified by:   John Cabuso  
 * @Description: PayApi.cls
 * @Requirement: This class handles the custom Rest API for demo. Implement an Apex function that can be called through a RESTful API.
 */

@RestResource(urlMapping='/CustomApi/*')
global with sharing class PayApi {

    // Get the org default URL
    public static final String MY_DOMAIN_URL = URL.getOrgDomainUrl().toExternalForm();

    // DEFAULT MESSAGE
    public static final STRING RECORD_CREATED = 'Record successfully created.';
    public static final Integer SUCCESS_CODE = 200;
    public static final STRING VALIDATION_ERROR = 'Request validation error.';
    public static final Integer VALIDATION_CODE = 300;
    public static final STRING BLANK_DATA_ERROR = 'No request data found.';
    public static final Integer BLANK_DATA_CODE = 400;
    public static final STRING BAD_REQUEST = 'Bad Request: Please contact system admin.';
    public static final Integer BAD_REQUEST_CODE = 500;

    /**
     * Details: Post response to create Contact and Account
     * This method will receive business name, email address, owner name, and monthly spend
     */
    @HttpPost
    global static CustomResponseWrapper doPost() {

        // Handle the return response
        CustomResponseWrapper response;

        try {
        
            // Bind the request JSON data to Map
            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            
            if (request.size() > 0) {

                // Validate the field data values
                Map<String, String> validateRes = validateContact(request);

                if (validateRes.size() == 0) {
                    // Insert account and contact record
                    Id recordId = upsertAccountAndContact(request);

                    // Create a map for returning contact record page
                    Map<String, String> responseRes = new Map<String, String>();
                    if (String.isNotEmpty(recordId.toString())) {
                        responseRes.put('recordPage', MY_DOMAIN_URL + '/lightning/r/Contact/' + recordId + '/view');
                    }

                    // return successful request
                    response = new CustomResponseWrapper(SUCCESS_CODE, RECORD_CREATED, JSON.serialize(responseRes));
                } else {
                    response = new CustomResponseWrapper(VALIDATION_CODE, VALIDATION_ERROR, JSON.serialize(validateRes));
                }
                
            } else {
                // return invalid payload request
                response = new CustomResponseWrapper(BLANK_DATA_CODE, BLANK_DATA_ERROR);
            }
        } catch (Exception e) {
            // return error message
            response = new CustomResponseWrapper(BAD_REQUEST_CODE, BAD_REQUEST, e.getMessage());
            // TODO: Add log to throw the response error from the custom Rest API
        }

        return response;
    }

    /**
     * Details: Handle the request map data and check all the field for validations
    */
    private static Map<String, String> validateContact(Map<String, Object> mapData) {

        Map<String, String> errorMap = new Map<String, String>();

        // START: Check all fields that are blank and missing
        if (!mapData.containsKey('name') || String.isEmpty(mapData.get('name').toString())) {
            errorMap.put('name', 'Name is blank');
        } else {
            
            // Get the map value for owner name
            String ownerName = mapData.get('name').toString();
            // Remove any leading or extra spaces
            ownerName = ownerName.trim();
            List<String> nameArr = ownerName.split(' ');

            // Check if Name contains atleast two words
            if (nameArr.size() == 1) {
                errorMap.put('name', 'Owner Name needs to have at least 2 words');
            }

            // Check if name has special character
            if (!ownerName.isAlphaNumericSpace()) {
                errorMap.put('name', 'Owner Name should only have Alphanumeric value');
            }
        }

        if (!mapData.containsKey('businessEmail') || String.isEmpty(mapData.get('businessEmail').toString())) {
            errorMap.put('businessEmail', 'Email is blank');
        }

        if (!mapData.containsKey('businessName') || String.isEmpty(mapData.get('businessName').toString())) {
            errorMap.put('businessName', 'Business name is blank');
        } else {
            
            // Get the map value for business name
            String busName = mapData.get('businessName').toString();
            // Remove any leading or extra spaces
            busName = busName.trim();

            // Check if business name begins with number
            if (busName.substring(0,1).isNumeric()) {
                errorMap.put('businessName', 'Business name cannot begin with a number');
            }

            // Check if name has special character
            if (!busName.isAlphaNumericSpace()) {
                errorMap.put('businessName', 'Business Name should only have Alphanumeric value');
            }
        }

        if (!mapData.containsKey('monthlySpending') || String.isEmpty(mapData.get('monthlySpending').toString())) {
            errorMap.put('monthlySpending', 'Monthly spending is blank');
        } else {
            // Check value if matched in Monthly Spending picklist values
            // Get the map value for monthly spending
            String monthlySpend = mapData.get('monthlySpending').toString();

            // Get the Monthly Spending field active values
            Schema.DescribeFieldResult fieldDescribe = Account.Monthly_Spending__c.getDescribe();
            List<Schema.PicklistEntry> fieldPicklist = fieldDescribe.getPicklistValues();
            List<String> validOptions = new List<String>();

            // Insert all the active value to a list
            for (Schema.PicklistEntry v : fieldPicklist) {
                if (v.isActive()) {
                    validOptions.add(v.getValue());
                }
            }

            // Check if monthly spending value is match to the picklist data
            if (!validOptions.contains(monthlySpend)) {
                errorMap.put('monthlySpending', 'Invalid Monthly spending');
            }
        }
        // END

        return errorMap;
    }

    /**
     * Details: Creates the account and contact if validation passed
    */
    private static Id upsertAccountAndContact(Map<String, Object> mapData) {

        String name = mapData.get('name').toString();
        String email = mapData.get('businessEmail').toString();
        String businessName = mapData.get('businessName').toString();
        String spending = mapData.get('monthlySpending').toString();

        String fname;
        String lname;
        // Remove leading and extra spaces
        name = name.trim();

        List<String> nameSplit = name.split(' ');
        fname = nameSplit[0];
        // remove the first index
        nameSplit.remove(0);
        // combine the remaining index for the last name
        lname = String.join(nameSplit, ' ');

        Account a = new Account(
            Name = businessName,
            Monthly_Spending__c = spending
        );

        upsert a;

        Contact c = new Contact(
            FirstName = fname,
            LastName = lname,
            Email = email,
            AccountId = a.Id
        );

        upsert c;

        return c.Id;
    }

    // Custom Response Wrapper to handle success and error 
    global class CustomResponseWrapper {

        public Integer statusCode;
        public String statusMessage;
        public String result;

        public CustomResponseWrapper(Integer code, String message, String data) {
            statusCode = code;
            statusMessage = message;
            result = data;
        }

        public CustomResponseWrapper(Integer code, String message) {
            statusCode = code;
            statusMessage = message;
        }  
    }
}