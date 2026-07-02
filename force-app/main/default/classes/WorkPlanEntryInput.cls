global class WorkPlanEntryInput {
    @InvocableVariable(label='Work Plan Template Id' required=true)
    @AuraEnabled
    global Id workPlanTemplateId;

    @InvocableVariable(label='Work Step Template Id' required=true)
    @AuraEnabled
    global Id workStepTemplateId;

    @InvocableVariable(label='Execution Order' required=true)
    @AuraEnabled
    global Integer executionOrder;

    @InvocableVariable(label='Is Required' required=false)
    @AuraEnabled
    global Boolean isRequired;

    @InvocableVariable(label='Name' required=true)
    @AuraEnabled
    global String name;
}