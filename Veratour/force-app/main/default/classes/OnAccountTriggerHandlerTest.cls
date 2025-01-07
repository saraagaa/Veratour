@isTest
private class OnAccountTriggerHandlerTest {

    static testMethod void ManageSlaveTest() {

	/*        
	Test for: 
		- CreateSlaveAssociation method
		- CreateSlaveMap method
	*/        

		Slave_Data_Mapping__c sdm = new Slave_Data_Mapping__c();
		sdm.Name 							= 'LastName';
		sdm.Nome_API_campo_Account__c 		= 'LastName';
		sdm.Nome_API_campo_Slave_Data__c 	= 'Cognome__c';
		insert sdm;
        
        Account a1 	= new Account();
        a1.LastName = 'TestLastName1';
        insert a1;
        
        Account a2 	= new Account();
        a2.LastName = 'TestLastName2';
        insert a2;
        
        Map_Slave__c ms = [Select id, Account__c from Map_Slave__c where Account__c =: a1.id];
        
        ms.Account__c = a2.Id;
        update ms;
        
        delete a1;
        
    }

    @isTest
    static void testAfterUpdate() {

        Account testAccount = new Account(
            FirstName = 'Test', LastName =  'Account',
            Veratour_WebFunnel_Email__c = 'oldemail@test.com'
        );
        insert testAccount;

        Case testCase = new Case(
            AccountId = testAccount.Id,
            Searchable_Contact_Email__c = null 
        );
        insert testCase;

        testAccount = [SELECT Id, Veratour_WebFunnel_Email__c FROM Account WHERE Id = :testAccount.Id];
        testCase = [SELECT Id, Searchable_Contact_Email__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals( 'oldemail@test.com', testAccount.Veratour_WebFunnel_Email__c,'Initial Veratour_WebFunnel_Email__c does not match');
        System.assertEquals( 'oldemail@test.com', testCase.Searchable_Contact_Email__c, 'Initial Searchable_Contact_Email__c should be oldemail@test.com');

        testAccount.Veratour_WebFunnel_Email__c = 'newemail@test.com';
        update testAccount;

        testCase = [SELECT Id, Searchable_Contact_Email__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals( 'newemail@test.com', testCase.Searchable_Contact_Email__c,'Searchable_Contact_Email__c was not updated correctly');
    }
    
}