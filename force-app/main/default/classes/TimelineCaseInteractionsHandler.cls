global with sharing class TimelineCaseInteractionsHandler extends timeline.AbstractTimelineDataProvider {
    /**
     * @description The child object name
     * @return  String
     */
    global override String getObjectName() {
        return 'Case';
    }

    /**
     * @description The label of the relationshipname of the child object
     * @return  String
     */
    global override String getRelationshipName() {
        return 'Related Cases';
    }
    
    /**
     * @description The field that is used as the title (flow step: Title field)
     * @return  String
     */
    global override String getTitleField() {
        return 'Subject';
    }

    /**
     * @description The field that is used as reference date (flow step: Date field)
     * @return  String
     */
    global override String getDateField() {
        return 'CreatedDate';
    }

    /**
     * @description The fields that are showed when expanded (flow step: Display fields)
     * @return  List<String>
     */
    global override List<String> getFieldsToDisplay() {
        return new List<String>{'Name','Subject', 'CreatedDate','Status'};
    }



    /**
     * @description This method returns the set of data
     * @param   recordId    The id of the parent record (in this case an Account Id)
     * @param   dateFilter  The dateFilter coming from the filters in the panel
     * @return  List<Object>
     */
    global override List<Object> getData(Id recordId, String dateFilter) {
        /**
         * Select all of the VoiceCalls that are related to this Case (SubQuery)
         * From there identify other Cases that originated from those calls
         **/ 
        System.debug('Fetching Related Cases for'+ recordId);
        
        Case thisCase = [select id, subject, OriginatingVoiceCall3__c 
                           from Case
							where id = :recordId];
                      
        List<Object> result = new List<Object>();
        for (Case item : [select id,subject, createddate, OriginatingVoiceCall3__c, Status 
                          From Case
                          where id in (select PrimaryCase__c from VoiceCall3__c
                                        where PrimaryCase__c = :thisCase.id
                                           or id = :thisCase.OriginatingVoiceCall3__c)]) {
                                          result.add(item);
                                       }
        return result;
    }  
}