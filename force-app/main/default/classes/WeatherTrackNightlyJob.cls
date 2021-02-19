public class WeatherTrackNightlyJob implements
    Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, BillingCity FROM Account'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> accs){
        List<Id> accsId = new List<Id>();

        for(Account acc : accs){
            List<Weather_Track__c> relatedTracker = [
                SELECT Id, Account__c, Created_Date__c
                FROM Weather_Track__c
                WHERE Account__c = :acc.Id
            ];
            if(relatedTracker.size() == 0){
                if(acc.BillingCity == null)continue;
                WeatherTrackNightlyJob.refreshAccountTracker(acc);
            }
            if((relatedTracker.size() != 0) && relatedTracker[0].Created_Date__c == System.today()){
                continue;
            }else{
                WeatherTrackNightlyJob.refreshAccountTracker(acc);
            }

        }
        if(accsId.size() != 0){
            for(Account acc : accs){
                WeatherTrackNightlyJob.refreshAccountTracker(acc);
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('All weather trackers updated');
        
    }

    public static void refreshAccountTracker(Account acc){
        update acc;
    }
}