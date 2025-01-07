public with sharing class CaseTriggerHandler {
    public static void afterCreation(List<Case> newCases) {

        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : newCases) {
            if (c.ContactEmail != null) {
                
                Case caseToUpdate = new Case(Id = c.Id);
                caseToUpdate.Searchable_Contact_Email__c = c.ContactEmail;
                casesToUpdate.add(caseToUpdate);
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    public static void beforeUpdate(Map<Id, Case> newCases, Map<Id, Case> oldCases) {
        Set<Id> contactIds = new Set<Id>();
        for (Case newCase : newCases.values()) {
            if (newCase.ContactId != null) {
                contactIds.add(newCase.ContactId);
            }
        }
    
        Map<Id, Contact> relatedContacts = new Map<Id, Contact>(
            [SELECT Id, Email FROM Contact WHERE Id IN :contactIds]
        );
    
        for (Id caseId : newCases.keySet()) {
            Case newCase = newCases.get(caseId);
            Case oldCase = oldCases.get(caseId);
    
            if (newCase.ContactId != null && relatedContacts.containsKey(newCase.ContactId)) {
                Contact relatedContact = relatedContacts.get(newCase.ContactId);
                newCase.Searchable_Contact_Email__c = relatedContact.Email;
            } else if (newCase.ContactId == null) {
                newCase.Searchable_Contact_Email__c = null;
            }
        }
    }
    
}