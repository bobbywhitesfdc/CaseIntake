@isTest
public class VoiceCallFactoryTest {
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
    private static VoiceCall createVC(final Contact theContact) {
        return new VoiceCall(CallType=INBOUND,
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
        VoiceCall voice = createVC(theContact);
		insert voice;
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c From VoiceCall 
                                   where RelatedRecordId=:theContact.Id
                                     and CallType= :INBOUND];
        
        System.AssertEquals(calls.size(),1,'Expected 1 IVR call');
        System.AssertEquals(calls[0].CallType,INBOUND,'Expected type Inbound');
        System.AssertEquals(calls[0].PrimaryCase__c,null,'Expected no PrimaryCase');
    }
    public static testMethod void OneAndDone() {
        final Contact theContact = getContact();

        
        Test.StartTest();
        
        // Create a Voice Call tied to a single Case
        VoiceCall voice = createVC(theContact);
		insert voice;
        
        Case theCase = createCase(theContact,voice);
        insert theCase;
        
        // Link the Case to the Voice Call
        voice.PrimaryCase__c=theCase.Id;
        update voice;
        
        
        Test.StopTest();
        
        // Assertions
        final VoiceCall[] calls = [select id, CallType,RelatedRecordId,PrimaryCase__c From VoiceCall 
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

}