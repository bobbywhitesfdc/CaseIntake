public class VCUtil {
    public static VoiceCall scenario(integer scenario) {
        List<VoiceCallTypeTemplate__mdt> configs = [select id, scenarioNumber__c, CallType__c, FromPhone__c, ToPhone__c
                                                    , IVR_Caller_Identified__c, IVR_Authenticated__c
                                                    , IVR_Company_Code__c, Branch__c, IVR_Contact_External_Id__c
                                             from VoiceCallTypeTemplate__mdt
                                             where ScenarioNumber__c = :scenario];
        
        if (configs.isEmpty()) {
            System.Debug('Scenario not found: ' + scenario);
            return null;
        }
                
        return createVC(configs[0]);
    }
    
    private static Id createAccount(final String companyCode) {
        List<Account> theAccounts = [select id from Account 
                                     Where IID__c = :companyCode 
                                     LIMIT 1];  // Unique External ID
        
        Account result=null;
        
        if (theAccounts.isEmpty()) {
            // Create it on the fly
            //### TODO Ensure that it's owned by the integration user
            result = new Account(IID__c=companyCode, name='Test Company: '+ companyCode);
            insert result;
            
        } else {
            result = theAccounts[0];
        }
        
        
        return result.Id;
    }
    
     private static Id createContact(final Id acctId, final String contactExtId) {
        List<Contact> theContacts = [select id, accountId from Contact 
                                     Where UCM_Row_Id__c  = :contactExtId 
                                     LIMIT 1];  // Unique External ID
        
        Contact result=null;
        
        
        if (theContacts.isEmpty()) {
            // Create it on the fly
            //### TODO Ensure that it's owned by the integration user
            result = new Contact(UCM_Row_Id__c=contactExtId
                                 , AccountId=acctId
                                 , FirstName='Test Contact: '+ contactExtId
                                 , LastName='TestContactLastname');
            insert result;
            
        } else {
            result = theContacts[0];
        }
        
        
        return result.Id;
    }

    
    private static VoiceCall createVC(final VoiceCallTypeTemplate__mdt config) { 
        final Id acctId = createAccount(config.IVR_Company_Code__c);
        final Id contactId = createContact(acctId,config.IVR_Contact_External_Id__c);
        
        VoiceCall myVC = new VoiceCall();
        myVC.CallCenterId = VCUtil.getCallCenter(); 
        myVC.CallType= config.CallType__c; 
        myVC.CallDisposition = 'Connected';
        myVC.FromPhoneNumber= config.FromPhone__c ;
        myVC.VendorCallKey='123'+ System.now();
        myVC.VendorType='ContactCenter';
        myVC.ToPhoneNumber=config.ToPhone__c;
        myVC.CallStartDateTime= Datetime.now()-300;
        myVC.CallEndDateTime= Datetime.now();
        // Custom fields
        myVC.GC_Branch_Code__c  = config.Branch__c;
        myVC.GC_Caller_Identified__c  = config.IVR_Caller_Identified__c.toString();
        myVC.IVR_AUTHENTICATED__c  = config.IVR_Authenticated__c.toString();
        myVC.GC_Company_Code__c = config.IVR_Company_Code__c;
        myVC.GC_Client_Id__c = config.IVR_Contact_External_Id__c;
        
        insert myVC;
        
        System.debug('VoiceCall: ' + myVC);
        return myVC;
    }
    
    private static Id getCallCenter() {
        User runningUser = [select id, callCenterId From User where Id = :UserInfo.getUserId()];
        return runningUser.callCenterId;
    }
    
    public static void createVC(final String fromNumber) {
        VoiceCall myVC = new VoiceCall();
        //myVC.CallCenterId = '04vDC000000Kz6lYAC';
        myVC.CallType='Inbound';
        myVC.CallDisposition = 'Connected';
        myVC.FromPhoneNumber= fromNumber;
        myVC.VendorCallKey='123'+ System.now();
        myVC.VendorType='ContactCenter';
        myVC.ToPhoneNumber='8006676389273';
        myVC.CallStartDateTime= Datetime.now()-300;
        myVC.CallEndDateTime= Datetime.now();
        
        insert myVC;
        
        System.debug('VoiceCall: ' + myVC);
    }
}

/**
 * {
    "CallCenterId": "04vDC000000Kz6lYAC",
    "CallType": "Inbound",
    "FromPhoneNumber": "{{FromPhoneNumber}}",
    "GC_Caller_Identified__c": "No",
    "GC_Conversation_Id__c": "494be377-957c-4f1f-a61d-f29f674d88d5",
    "GC_IVR_Language__c": "English",
    "GC_Menu_Selected__c": "AnythingElse",
    "IVR_AUTHENTICATED__c": "No",
    "VendorCallKey": "8e54d47a-d08e-4e0f-9ec5-aadb9456b0eb:66163a6d-202b-4698-9369-69864c8e2740",
    "VendorType": "ContactCenter",
    "CallStartDateTime": "2024-06-11T19:19:29.000Z",
    "CallEndDateTime": "2024-06-11T19:29:29.000Z",
    "ToPhoneNumber": "+13160070070"
  }
 * 
 **/