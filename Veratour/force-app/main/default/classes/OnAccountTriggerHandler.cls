public with sharing class OnAccountTriggerHandler {

    public static void CreateSlaveMap(list<Account> newAccount){
 
		list<Map_Slave__c> ListMapSlave	= new list<Map_Slave__c>();
		       
		for(Account a:newAccount){
			// creo per ogni nuova anagrafica il corrispettivo record 
			// Map_Slave__c che verrà utilizzato a fronte di una deduplica
			Map_Slave__c ms		= new Map_Slave__c();
			ms.Name				= a.Id;
			ms.Account__c		= a.Id;
			ms.Id_Account__c	= a.Id;
			
			ListMapSlave.add(ms);
		
		}

		if(ListMapSlave.size()>0){			
		
			insert ListMapSlave;
		
		}

    }

    public static void CreateSlaveAssociation(list<Account> oldAccount){
 
		set<string> AccountIds 					= new set<string>();
		map<string, Account> MapAccount 		= new map<string, Account>();
		list<Slave_Data__c> ListSlave 			= new list<Slave_Data__c>();
		list<Map_Slave__c> ListMapSlaveToDelete	= new list<Map_Slave__c>();
		set<string> MasterAccountIds			= new set<string>();
		
		// Ciclo tutte le anagrafiche cancellate      
		for(Account a:oldAccount){
			// Popolo un set di id da utilizzare come filtro nella query per recuperare i master record
			AccountIds.add(a.id);
			// Popolo la mappa con i dati delle anagrafiche cancellate
			MapAccount.put(a.id,a);		
		}
		
		// Query per recuprerare gli id delle anagrafiche a partire 
		// dall'oggetto Map_Slave__c che la deduplica a correlato ai master
		list<Map_Slave__c> listMapSlave = [	select 	Id_Account__c, 
													Account__c 
											from Map_Slave__c 
											where Id_Account__c IN:AccountIds];

		map<String, Slave_Data_Mapping__c> SlaveDataMapping = Slave_Data_Mapping__c.getAll();
		

		for(Map_Slave__c m:listMapSlave){
		
			if(MapAccount.containsKey(m.Id_Account__c)){
				// Creo il nuovo record con i dati dello slave correlato al master
				Slave_Data__c sd 			= new Slave_Data__c();
				sd.Account__c				= m.Account__c;
				sd.Name						= MapAccount.get(m.Id_Account__c).FirstName + ' ' + MapAccount.get(m.Id_Account__c).LastName;				
				sd.Id_Cliente_Salesforce__c = MapAccount.get(m.Id_Account__c).Id;

				for(Slave_Data_Mapping__c sdm:SlaveDataMapping.values()) {
					
					sd.put(sdm.Nome_API_campo_Slave_Data__c,(MapAccount.get(m.Id_Account__c)).get(sdm.Nome_API_campo_Account__c));

        		}
	
				ListSlave.add(sd);
				ListMapSlaveToDelete.add(m);				
				MasterAccountIds.add(m.Account__c);
			
			}
		
		}
       
		if(ListSlave.size()>0){			
			// inserisco i dati degli slave
			insert ListSlave;
		
		}
      
		if(ListMapSlaveToDelete.size()>0){			
			// Cancello i record di Map_Slave__c che non servono in quanto 
			// l'anagrafica slave è stata cancellata a fronte del merge
			delete ListMapSlaveToDelete;
		
		}	
		
    }


	public static void afterUpdate(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {

		Set<Id> accountIdsToUpdate = new Set<Id>();
	
		for (Id accountId : newAccounts.keySet()) {
			Account newAccount = newAccounts.get(accountId);
			Account oldAccount = oldAccounts.get(accountId);
	
			if (newAccount.Veratour_WebFunnel_Email__c != oldAccount.Veratour_WebFunnel_Email__c) {
				accountIdsToUpdate.add(accountId);
			}
		}

		if (accountIdsToUpdate.isEmpty()) {
			return;
		}
	
		List<Case> casesToUpdate = [
			SELECT Id, Searchable_Contact_Email__c, Account.Veratour_WebFunnel_Email__c, AccountId 
			FROM Case 
			WHERE AccountId IN :accountIdsToUpdate
		];

		for (Case caseRecord : casesToUpdate) {
			if (caseRecord.Account.Veratour_WebFunnel_Email__c != null) {
				caseRecord.Searchable_Contact_Email__c = caseRecord.Account.Veratour_WebFunnel_Email__c;
			}
		}
	
		if (!casesToUpdate.isEmpty()) {
			try {
				update casesToUpdate;
			} catch (DmlException e) {
				System.debug('Error updating cases: ' + e.getMessage());
				throw e;
			}
		}
	}
}