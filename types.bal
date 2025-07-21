// Request payload structure
public type InvoiceRequest record {
    decimal totalAmount;
    string countryCode;
};

// Tax rate response structure
public type TaxRateResponse record {
    decimal taxRate;
    string countryCode;
};

// Final response structure
public type InvoiceResponse record {
    decimal finalAmount;
};