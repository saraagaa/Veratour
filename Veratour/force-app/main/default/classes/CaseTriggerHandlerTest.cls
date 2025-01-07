@isTest
public with sharing class CaseTriggerHandlerTest {
     private static User createTestUser() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'testusr',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = adminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        return testUser;
    }

    @isTest
    static void testAfterCreation() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            RecordType accountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Account personale' LIMIT 1];
            Account testAccount = new Account(FirstName = 'Test', LastName = 'Account', Veratour_WebFunnel_Email__c = 'testaccount@example.com', RecordTypeId = accountRecordType.Id);
            
            insert testAccount;

            Case testCase = new Case(Subject = 'Test Case 1', Description = 'Test1', AccountId = testAccount.Id,  Status = 'Nuovo', Origin = 'Phone');
            insert testCase;

            Case insertedCase = [SELECT Id, ContactEmail, Searchable_Contact_Email__c FROM Case WHERE Id = :testCase.Id];

            System.assertNotEquals(null, insertedCase.ContactEmail, 'ContactEmail should be populated automatically.');
            System.assertEquals(insertedCase.ContactEmail, insertedCase.Searchable_Contact_Email__c, 'Searchable_Contact_Email__c should match ContactEmail');
        }
    }

 
}