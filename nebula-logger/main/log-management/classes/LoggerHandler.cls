//------------------------------------------------------------------------------------------------//
// This file is part of the Nebula Logger project, released under the MIT License.                //
// See LICENSE file or go to https://github.com/jongpie/NebulaLogger for full license details.    //
//------------------------------------------------------------------------------------------------//

/**
 * @group Log Management
 * @description Abstract class used by trigger handlers for shared logic
 */
 public abstract class LoggerHandler {

    protected void executePostProcessors(List<SObject> loggerRecords, Map<Id, SObject> oldLoggerRecordsById) {
        if (loggerRecords == null) {
            return;
        }

        String sobjectTypeCmdtName = loggerRecords.getSObjectType().getDescribe().getName().replace('__c', '');

        List<LoggerHandlerConfiguration__mdt> loggerHandlerConfigurations = [
            SELECT ApexClassName__c, FlowName__c
            FROM LoggerHandlerConfiguration__mdt
            WHERE LoggerSObject__r.DeveloperName = :sobjectTypeCmdtName AND IsActive__c = TRUE
        ];
        LoggerHandlerConfiguration__mdt loggerHandlerConfiguration = loggerHandlerConfigurations.isEmpty() ? null : loggerHandlerConfigurations.get(0);

        executeApexClass(loggerHandlerConfiguration?.ApexClassName__c, loggerRecords, oldLoggerRecordsById);
        executeFlow(loggerHandlerConfiguration?.FlowName__c, loggerRecords, oldLoggerRecordsById);
    }

    private void executeApexClass(String apexClassName, List<SObject> loggerRecords, Map<Id, SObject> oldLoggerRecordsById) {
        if (String.isBlank(apexClassName)) {
            return;
        }

        Type postProcessorType = Type.forName(apexClassName);
        LoggerPostProcessor recordPostProcessor = (LoggerPostProcessor) postProcessorType.newInstance();
        recordPostProcessor.execute(Trigger.operationType, loggerRecords, oldLoggerRecordsById);
    }

    private void executeFlow(String flowName, List<SObject> loggerRecords, Map<Id, SObject> oldLoggerRecordsById) {
        if (String.isBlank(flowName)) {
            return;
        }

        Map<String, Object> flowInputs = new Map<String, Object>();
        flowInputs.put('records', loggerRecords);
        flowInputs.put('oldRecords', oldLoggerRecordsById?.values());
        flowInputs.put('triggerOperation', Trigger.operationType);

        Flow.Interview recordFlow = Flow.Interview.createInterview(flowName, flowInputs);
        recordFlow.start();
    }
}