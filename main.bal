import ballerina/http;

// Configurable for external tax rate service URL
configurable string taxRateServiceUrl = "http://localhost:8080";

// HTTP client for external tax rate service
http:Client taxRateClient = check new (taxRateServiceUrl);

// Invoice service
service /invoiceservice on new http:Listener(8090) {
    
    resource function post invoice(@http:Payload InvoiceRequest invoiceRequest) returns InvoiceResponse|http:InternalServerError {
        
        // Extract values from request
        decimal totalAmount = invoiceRequest.totalAmount;
        string countryCode = invoiceRequest.countryCode;
        
        // Make external call to get tax rate
        http:Response|error taxRateResponse = taxRateClient->get(string `/rate/${countryCode}`);
        
        if taxRateResponse is error {
            return <http:InternalServerError>{
                body: "Failed to fetch tax rate"
            };
        }
        
        // Parse the tax rate response
        json|error taxRateJson = taxRateResponse.getJsonPayload();
        if taxRateJson is error {
            return <http:InternalServerError>{
                body: "Failed to parse tax rate response"
            };
        }
        
        // Convert JSON to record
        TaxRateResponse|error taxRateRecord = taxRateJson.cloneWithType(TaxRateResponse);
        if taxRateRecord is error {
            return <http:InternalServerError>{
                body: "Invalid tax rate response format"
            };
        }
        
        // Calculate final amount with tax
        decimal taxRate = taxRateRecord.taxRate;
        decimal taxAmount = totalAmount * taxRate / 100;
        decimal finalAmount = totalAmount + taxAmount;
        
        // Return the final amount
        return {
            finalAmount: finalAmount
        };
    }
}