trigger AccountTrigger on Account (after insert, after update) {
    List<Id> accsId = new List<Id>();
    System.Debug('OPA');
    System.Debug(Trigger.isUpdate);
    System.Debug(Trigger.isInsert);

    if(Trigger.isUpdate || Trigger.isInsert){
        for(Account acc : Trigger.new){
            accsId.add(acc.Id);
            if(accsId.size() == 45){
                WeatherTrackController.assignWeatherTrackersToAccounts(accsId);
                accsId.clear();
            }
        }
        System.Debug('Ost');
        System.Debug(accsId.size());
        if(accsId.size() != 0){
            System.Debug('good');
            System.Debug(accsId.size());
            WeatherTrackController.assignWeatherTrackersToAccounts(accsId);
            accsId.clear();
        }
    }
}