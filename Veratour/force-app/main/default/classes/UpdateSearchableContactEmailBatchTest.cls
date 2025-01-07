@isTest
public class UpdateSearchableContactEmailBatchTest {

    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(
                LastName = 'LastName ' + i,
                Veratour_WebFunnel_Email__c = 'test' + i + '@example.com'
            ));
        }
        insert accounts;

        List<Case> cases = new List<Case>();
        for (Account acc : [SELECT Id, Veratour_WebFunnel_Email__c, LastName FROM Account]) {
            cases.add(new Case(
                Subject = 'Test Case for ' + acc.LastName,
                Status = 'Nuovo',
                AccountId = acc.Id
            ));
        }
        insert cases;
    }

    @isTest
    static void testBatchExecution() {
       
        List<Case> casesBefore = [
            SELECT Id, ContactEmail, Searchable_Contact_Email__c 
            FROM Case 
            WHERE ContactEmail != ''
        ];
        System.assertNotEquals(0, casesBefore.size(), 'Test data was not created.');

        Test.startTest();
        UpdateSearchableContactEmailBatch batch = new UpdateSearchableContactEmailBatch();
        ID batchJobId = Database.executeBatch(batch);
        Test.stopTest();

        List<Case> casesAfter = [
            SELECT Id, ContactEmail, Searchable_Contact_Email__c 
            FROM Case 
            WHERE ContactEmail != ''
        ];

        for (Case c : casesAfter) {
            System.assertEquals(c.ContactEmail,  c.Searchable_Contact_Email__c,'The Searchable_Contact_Email__c field was not updated correctly.');
        }
    }


}