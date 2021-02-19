public inherited sharing class WeatherTrackController {
    @future(callout=true)
    public static void assignWeatherTrackersToAccounts(List<Id> relatedAccountsId) {
        Map<Id, Account> accountCity = new Map<Id, Account>([
            SELECT BillingCity 
            FROM Account
            WHERE Id IN :relatedAccountsId
        ]);

        Http http = new Http();
        for(Id accId: relatedAccountsId){
            if(accountCity.get(accId).BillingCity == null){
                WeatherTrackController.deleteAccountWeatherTrackIfExist(accId);
            }
            HttpRequest request = new HttpRequest();
            String apiKey = '14789085edf228c5b79d3f4a4607ca82';
            String requestEndpoint = 'https://api.openweathermap.org/data/2.5/weather';
            requestEndpoint += '?q=' + accountCity.get(accId).BillingCity;
            requestEndpoint += '&appid=' + apiKey;
            
            request.setEndpoint(requestEndpoint);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 201) {
                JSONParser parser = JSON.createParser(response.getBody());
                
                WeatherTrackController.deleteAccountWeatherTrackIfExist(accId);
                Weather_Track__c tracker = WeatherTrackController.createWeatherTrackerFromJSON(parser, accId);
                
                insert tracker;
               
            } else {
                System.debug(response.getBody());
            }
        }
    }

    public static void deleteAccountWeatherTrackIfExist(Id accId){
        List<Weather_Track__c> tracker = [
            SELECT Id, Account__c
            FROM Weather_Track__c
            WHERE Account__c = :accId
        ];

        if(tracker.size() != 0){
            delete tracker;
        }
    }

    public static Weather_Track__c createWeatherTrackerFromJSON(JSONParser parser, Id accId){
        Decimal temp;
        Decimal pressure;
        Decimal humidity;
        String description;
        while (parser.nextToken() != null) {
            if(parser.getText() == 'temp'){
                parser.nextToken();
                temp = parser.getDecimalValue();
            }
            if(parser.getText() == 'pressure'){
                parser.nextToken();
                pressure = parser.getDecimalValue();
            }
            if(parser.getText() == 'humidity'){
                parser.nextToken();
                humidity = parser.getDecimalValue();
            }
            if(parser.getText() == 'description'){
                parser.nextToken();
                description = parser.getText();
            }
        }
        Weather_Track__c tracker = new Weather_Track__c(Kelvin__c = temp, Pressure__c = pressure, 
                                                        Humidity__c = humidity, Description__c = description,
                                                        Account__c = accId);
        return tracker;
    }
}
