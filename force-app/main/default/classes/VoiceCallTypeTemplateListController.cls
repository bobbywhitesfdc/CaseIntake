/**
 * Custom List Controller for VoiceCallTypeTemplate
 **/ 
public class VoiceCallTypeTemplateListController {
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [select id, developername, scenarioNumber__c
                     , CallType__c, FromPhone__c, ToPhone__c
                     , IVR_Caller_Identified__c, IVR_Authenticated__c
                     , IVR_Company_Code__c, Branch__c, IVR_Contact_External_Id__c
                     FROM VoiceCallTypeTemplate__mdt Order By scenarioNumber__c]));
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<VoiceCallTypeTemplate__mdt> getTemplates() {
        return (List<VoiceCallTypeTemplate__mdt>) setCon.getRecords();
    }
}