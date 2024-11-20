public class VoiceCallScenarioDetailController {
    private final VoiceCallTypeTemplate__mdt template;

    public VoiceCallScenarioDetailController() {
        template = [select id, developername, scenarioNumber__c
                     , CallType__c, FromPhone__c, ToPhone__c
                     , IVR_Caller_Identified__c, IVR_Authenticated__c
                     , IVR_Company_Code__c, Branch__c, IVR_Contact_External_Id__c
                    FROM VoiceCallTypeTemplate__mdt 
                    WHERE id = :ApexPages.currentPage().getParameters().get('id')] ;
    }

    public VoiceCallTypeTemplate__mdt getTemplate() {
        return template;
    }

    public PageReference execute() {
        final VoiceCall result = VCUtil.createVC(template);
        PageReference destination = new ApexPages.StandardController(result).view();
        destination.setRedirect(true);
        return destination;
    }
}