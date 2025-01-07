global class UpdateSearchableContactEmailBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Define the query to fetch cases with ContactEmail and AccountId populated
        return Database.getQueryLocator([
            SELECT Id, ContactEmail, Searchable_Contact_Email__c  
            FROM Case 
            WHERE  ContactEmail != '' 
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        // Iterate through cases and update Searchable_Contact_Email__c
        for (Case c : caseList) {
            c.Searchable_Contact_Email__c = c.ContactEmail;
        }
        update caseList; // Perform a bulk update
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optionally, send a notification or log the completion
        System.debug('Batch processing complete : '+bc.getJobId());
    }
}