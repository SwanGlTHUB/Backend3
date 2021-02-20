trigger AccountTrigger on Account (after insert, after update) {
    List<Id> accsId = new List<Id>();

    if(Trigger.isUpdate || Trigger.isInsert && !System.isBatch()){
        for(Account acc : Trigger.new){
            accsId.add(acc.Id);
            if(accsId.size() == 20){
                WeatherTrackController.assignWeatherTrackersToAccounts(accsId);
                accsId.clear();
            }
        }
        if(accsId.size() != 0){
            WeatherTrackController.assignWeatherTrackersToAccounts(accsId);
            accsId.clear();
        }
    }
}