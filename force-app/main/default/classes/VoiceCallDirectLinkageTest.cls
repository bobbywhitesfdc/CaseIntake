@isTest
public class VoiceCallDirectLinkageTest {
    // Call Center doesn't support DML, it must be configured/deployed through Setup
    private static final Id CALLCENTERID = [select Id from CallCenter limit 1].id;
    private static final String IVRTYPE='IVR';
    private static final String INBOUND='Inbound';
    
    @testsetup
    public static void setup() {
        Account a1 = new Account(name='ACME');
        insert a1;
        Contact c1 = new Contact(FirstName='Boone',Lastname='White',email='boone@example.com',AccountId=a1.id);
        insert c1;
        
    }
    /*
* Helper method to create the Voicecall record
*/ 
    private static VoiceCall createVC(final string vendorExtId, final Contact theContact) {
        return new VoiceCall(CallType=INBOUND, vendorCallKey = vendorExtId,
                             CallStartDateTime=System.now(),CallEndDateTime=System.now()+10,
                             FromPhoneNumber='7777777778', ToPhoneNumber='8888888888',
                             CallCenterId = CALLCENTERID,
                             RelatedRecordId=theContact.id);
        
    }
    
    private static Contact getContact() {
        return [Select Id, AccountId, Name, Email
                from Contact 
                where email='boone@example.com' LIMIT 1];
    }
    
    private static Case createCase(final Contact theContact,final VoiceCall voice) {
        return new Case(Subject='Test'
                        ,AccountId=(theContact != null ? theContact.AccountId : null)
                        ,ContactId=(theContact != null ? theContact.Id : null)
                        ,OriginatingVoiceCall__c = (voice!=null ? voice.id : null));
    }
    public static testMethod void IVRContainedCall() {
        final Contact theContact = getContact();
        
        
        
        Test.StartTest();
        // Create a single IVR contained Call, not tied to a Case
        VoiceCall voice = createVC('1',theContact);
        insert voice;
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c, vendorCallKey From VoiceCall 
                                   where RelatedRecordId=:theContact.Id
                                   and CallType= :INBOUND];
        
        System.AssertEquals(calls.size(),1,'Expected 1 IVR call');
        System.AssertEquals(calls[0].CallType,INBOUND,'Expected type Inbound');
        System.AssertEquals(calls[0].PrimaryCase__c,null,'Expected no PrimaryCase');
    }
    
    public static testMethod void oneAndDone() {
        final Contact theContact = getContact();
        
        
        Test.StartTest();
        
        // Create a Voice Call tied to a single Case
        VoiceCall voice = createVC('1',theContact);
        insert voice;
        
        Case theCase = createCase(theContact,voice);
        insert theCase;
        
        // Link the Case to the Voice Call
        voice.PrimaryCase__c=theCase.Id;
        update voice;
        
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c, vendorCallKey  From VoiceCall 
                                   where RelatedRecordId=:theContact.Id
                                   and CallType= :INBOUND];
        
        System.AssertEquals(calls.size(),1,'Expected 1 call');
        System.AssertEquals(calls[0].CallType,INBOUND,'Expected type Inbound');
        System.AssertEquals(calls[0].PrimaryCase__c,theCase.Id,'Expected a PrimaryCase');
        
        final Case[] cases = [select Id, Subject,OriginatingVoiceCall__c ,ContactId 
                              From Case];
        
        System.AssertEquals(cases.size(),1,'Expected 1 case');
        System.AssertEquals(cases[0].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[0].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call record');
    }
    
    public static testMethod void repeatCall() {
        final Contact theContact = getContact();
        
        
        Test.StartTest();
        
        // Create a Voice Call tied to a single Case - 
        VoiceCall voice1 = createVC('1',theContact);
        insert voice1;
        
        Case theCase = createCase(theContact,voice1);
        insert theCase;
        
        // Link the Case to the first Voice Call
        voice1.PrimaryCase__c=theCase.Id;
        update voice1;
        
        // Create a  2nd Voice Call tied to an existing Case - 
        VoiceCall voice2 = createVC('2',theContact);
        voice2.PrimaryCase__c = theCase.id;
        insert voice2;
        
        
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c,vendorCallKey From VoiceCall 
                                   where RelatedRecordId=:theContact.Id
                                   and CallType= :INBOUND
                                   order by vendorCallKey ASC];
        
        System.AssertEquals(calls.size(),2,'Expected 2 calls');
        System.AssertEquals(calls[0].CallType,INBOUND,'Expected type Inbound');
        System.AssertEquals(calls[0].PrimaryCase__c,theCase.Id,'Expected a PrimaryCase');
        System.AssertEquals('1',calls[0].vendorCallKey);
        System.AssertEquals(calls[1].CallType,INBOUND,'2nd Call, Expected type Inbound');
        System.AssertEquals(calls[1].PrimaryCase__c,theCase.Id,'2nd Call,Expected a PrimaryCase');
        System.AssertEquals('2',calls[1].vendorCallKey);
        
        final Case[] cases = [select Id, Subject,OriginatingVoiceCall__c ,ContactId, OriginatingVoiceCall__r.VendorCallKey
                              From Case];
        
        System.AssertEquals(cases.size(),1,'Expected 1 case');
        System.AssertEquals(cases[0].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[0].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call#1 record');
        System.AssertEquals('1',cases[0].OriginatingVoiceCall__r.VendorCallKey);
    }
    
    /**
* Two calls tied to the same Case
**/
    public static testMethod void transferCall() {
        final Contact theContact = getContact();
        
        
        Test.StartTest();
        
        // Create a Voice Call tied to a single Case - 
        VoiceCall voice1 = createVC('1',theContact);
        insert voice1;
        
        Case theCase = createCase(theContact,voice1);
        insert theCase;
        
        // Link the Case to the first Voice Call
        voice1.PrimaryCase__c=theCase.Id;
        update voice1;
        
        // Create a  2nd Voice Call (Transfer) tied to an existing Case - 
        VoiceCall voice2 = createVC('2',theContact);
        voice2.PrimaryCase__c = theCase.id;
        voice2.PreviousCallId = voice1.id; // tie to the initial call
        insert voice2;
        
        /** NextCallID isn't writeable via DML
voice1.NextCallId = voice2.id; // tie original call to transfered call
update voice1;
**/
        
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c, PreviousCallId,NextCallId
                                   From VoiceCall 
                                   where RelatedRecordId=:theContact.Id
                                   and CallType= :INBOUND];
        
        System.AssertEquals(calls.size(),2,'Expected 2 calls');
        System.AssertEquals(calls[0].CallType,INBOUND,'Expected type Inbound');
        System.AssertEquals(calls[0].PrimaryCase__c,theCase.Id,'Expected a PrimaryCase');
        //System.AssertEquals(calls[0].NextCallId,calls[1].Id,'Transfer tied to Next call'); // Can't set this via DML
        
        System.AssertEquals(calls[1].CallType,INBOUND,'2nd Call, Expected type Inbound');
        System.AssertEquals(calls[1].PrimaryCase__c,theCase.Id,'2nd Call,Expected a PrimaryCase');
        System.AssertEquals(calls[1].PreviousCallId,calls[0].Id,'Transferred call tied to original call');
        
        final Case[] cases = [select Id, Subject,OriginatingVoiceCall__c ,ContactId 
                              From Case];
        
        System.AssertEquals(cases.size(),1,'Expected 1 case');
        System.AssertEquals(cases[0].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[0].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call#1 record');
    }
    
    /**
     * 1 call, 2 cases
     **/  
    public static testMethod void multiCaseCall() {
        final Contact theContact = getContact();
        
        
        Test.StartTest();
        
        // Create a Voice Call tied to a single Case - 
        VoiceCall voice1 = createVC('1',theContact);
        insert voice1;
        
        Case theCase1 = createCase(theContact,voice1);
        insert theCase1;
        
        // Link the Case to the first Voice Call
        voice1.PrimaryCase__c=theCase1.Id;
        update voice1;
        
        // Create a  2nd Case - lined to the original Voice Call
        Case theCase2 = createCase(theContact,voice1);
        insert theCase2;
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c, PreviousCallId,NextCallId
                                   From VoiceCall 
                                   where RelatedRecordId=:theContact.Id
                                   and CallType= :INBOUND];
        
        System.AssertEquals(calls.size(),1,'Expected 1 calls');
        System.AssertEquals(calls[0].CallType,INBOUND,'Expected type Inbound');
        System.AssertEquals(calls[0].PrimaryCase__c,theCase1.Id,'Expected a PrimaryCase');
        
        // Now get all of the Cases tied to the one original Voicecall
        final Case[] cases = [select Id, Subject,OriginatingVoiceCall__c ,ContactId 
                              From Case
                              where OriginatingVoiceCall__c = :voice1.id];
        
        System.AssertEquals(cases.size(),2,'Expected 2 cases');
        System.AssertEquals(cases[0].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[0].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call#1 record');
        System.AssertEquals(cases[1].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[1].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call#1 record');
    }
    
/*
* In this scenario we have:
*  1 initial call spanning two cases (multi-case call)
*  2 the second case gets transferred to another associate creating a 2nd Voicecall record.
*/
    public static testMethod void multiCaseCallWithTransfer() {
        final Contact theContact = getContact();
        
        
        Test.StartTest();
        
        // Create a Voice Call tied to a single Case - 
        VoiceCall voice1 = createVC('1',theContact);
        insert voice1;
        
        Case theCase1 = createCase(theContact,voice1);
        insert theCase1;
        
        // Link the Case to the first Voice Call
        voice1.PrimaryCase__c=theCase1.Id;
        update voice1;
        
        // Create a  2nd Case - linked to the original Voice Call
        Case theCase2 = createCase(theContact,voice1);
        insert theCase2;
        
        // Create a  2nd Voice Call (Transfer) tied to the 2nd Case - 
        VoiceCall voice2 = createVC('2',theContact);
        voice2.PrimaryCase__c = theCase2.id;
        voice2.PreviousCallId = voice1.id; // tie to the initial call
        insert voice2;
        
        
        Test.StopTest();
        
        // Get all calls tied to Cases via the Case relationship (Case-->VoiceCall)
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c, PreviousCallId,NextCallId
                                   From VoiceCall 
                                   //where Id IN (select OriginatingVoiceCall__c from Case)
                                  ];
        
        System.AssertEquals(2,calls.size(),'Expected 2 calls');
        System.AssertEquals(calls[0].PrimaryCase__c,theCase1.Id,'Expected a Case#1');
        System.AssertEquals(calls[1].PrimaryCase__c,theCase2.Id,'Expected a Case#2');
        
        // Now get all of the Cases tied to the one original Voicecall via PrimaryCase (VoiceCall-->Case)
        final Case[] cases = [select Id, Subject,OriginatingVoiceCall__c ,ContactId 
                              From Case
                              where OriginatingVoiceCall__c = :voice1.id];
        
        System.AssertEquals(2,cases.size(),'Expected 1 cases');
        System.AssertEquals(cases[0].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[0].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call#1 record');
        System.AssertEquals(cases[1].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases[1].OriginatingVoiceCall__c ,calls[0].id,'Should be tied to the Voice Call#1 record');
        
        // Now get all of the cases tied to Voice Call #2 via PrimaryCase
        // Now get all of the Cases tied to the one original Voicecall via PrimaryCase (VoiceCall-->Case)
        final Case[] cases2 = [select Id, Subject,OriginatingVoiceCall__c ,ContactId, OriginatingVoiceCall__r.vendorCallKey 
                               From Case
                               where Id = :voice2.PrimaryCase__c];
        
        System.AssertEquals(1,cases2.size(),'Expected 1 cases');
        System.AssertEquals(cases2[0].ContactId,theContact.Id,'Should be tied to the Contact');
        System.AssertEquals(cases2[0].OriginatingVoiceCall__c ,voice1.id,'Should be tied to the Voice Call#1 record');
        System.AssertEquals('1',cases2[0].OriginatingVoiceCall__r.vendorCallKey ,'Should be tied to the Voice Call#1 record vendorCallKey');
        
    }
    
}