public with sharing class BulkCallout {
    private static final String TOKEN='00D5g00000647g2!AQIAQJM0gWwmVIlZmFFJd8kmEbKnwTJPqTLJAehXOSwjhlNWahfCWPMNAHdG8qORP78EtkRoQw1vbst.ZZEldK5W6ClVg68g';
    private static final String INSTANCE_URL='https://epam-13e-dev-ed.my.salesforce.com' + '/services/data/v52.0/jobs/ingest' ;

    private static String bigFatString='';

    @future(callout=true)
    public static void sendBigFatString(Integer howManyThousand) {
        makeBigfatString(howManyThousand);
        String jobId = postJobRequestAndGetId();
        sendBulkData(jobId);
        closeJob(jobId);
    }

    public static void makeBigfatString(Integer howManyThousand){
            bigFatString = '"Name","Rating__c"';
            String thousandString='';
            for (Integer i = 0; i < 1000; i++) {
                thousandString = thousandString + '\n' + '"A",' + (Math.random()*101).intValue();
            }
            for (Integer i = 0; i < howManyThousand; i++) {
                bigFatString = bigFatString + thousandString;
            }
            System.debug('bigFatString, length = ' + bigFatString.length());
    }

    private static void sendBulkData(String jobId) {
        HttpRequest request = new HttpRequest();
        setRequestHeader(request);
        request.setHeader('Content-Type', 'text/csv');
        request.setEndpoint(INSTANCE_URL + '/' + jobId + '/batches');
        request.setMethod('PUT');
        request.setBody(bigFatString);
        Http http = new Http();
        System.debug('sendBulkData');
        try {
            httpResponse response = http.send(request);
            System.debug(response.getBody());
        } catch (System.CalloutException e) {
            System.debug(e);
        }
    }


    private static void closeJob(String jobId) {
        HttpRequest request = new HttpRequest();
        setRequestHeader(request);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(INSTANCE_URL + '/' + jobId);
        request.setMethod('PATCH');
        String body = '{"state" : "UploadComplete"}';
        request.setBody(body);
        Http http = new Http();
        System.debug('closeJob');
        try {
            httpResponse response = http.send(request);
            System.debug(response.getBody());
        } catch (System.CalloutException e) {          
            System.debug(e);
        }
    }
    
    private static String postJobRequestAndGetId(){
        HttpRequest request = new HttpRequest();
        setRequestHeader(request);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(INSTANCE_URL);
        request.setMethod('POST');
        String body = '{"operation" : "insert","object" : "Product2","contentType" : "CSV","lineEnding" : "LF"}';
        request.setBody(body);
        Http http = new Http();
        String jobId;
        try {
            httpResponse response = http.send(request);
            System.debug(response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    parser.nextToken();
                    jobId = parser.getText();                }
            }
            return jobId;
        } catch (System.CalloutException e) {
            System.debug(e);
            return '';
        }
    }

    private static void setRequestHeader(HttpRequest request) {
        request.setHeader('Authorization', 'Bearer ' + TOKEN);
        request.setHeader('Accept', 'application/json');
    }

}