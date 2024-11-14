public class VCUtil {
    public static void createVC(final String fromNumber) {
        VoiceCall myVC = new VoiceCall();
        myVC.CallCenterId = '04vDC000000Kz6lYAC';
        myVC.CallType='Inbound';
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