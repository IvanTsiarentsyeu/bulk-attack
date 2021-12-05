public with sharing class BulkCalloutBattery {
    public static void fire(Integer howManyBulks, Integer howManyThousand) {
        for (Integer i=0; i < howManyBulks; i++) {
            BulkCallout.sendBigFatString(howManyThousand);
        }
    }
}
