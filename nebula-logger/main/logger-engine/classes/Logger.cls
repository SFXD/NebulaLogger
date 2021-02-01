/*************************************************************************************************
 * This file is part of the Nebula Logger project, released under the MIT License.                *
 * See LICENSE file or go to https://github.com/jongpie/NebulaLogger for full license details.    *
 *************************************************************************************************/
global without sharing class Logger {
    private static final List<LogEntryEventBuilder> LOG_ENTRIES = new List<LogEntryEventBuilder>();
    private static final String TRANSACTION_ID = System.Request.getCurrent().getRequestId();

    private static final LoggingLevel USER_LOGGING_LEVEL = getLoggingLevel(
        LoggerSettings__c.getInstance().LoggingLevel__c
    );

    private static final QueueableSaver ASYNC_SAVER_INSTANCE = new QueueableSaver();

    private static String parentLogTransactionId;
    private static Boolean suspendSaving = false;
    private static Quiddity transactionSaveMethod = System.Request.getCurrent().getQuiddity();

    static {
        // If settings have not been configured, then insert the org defaults
        LoggerSettings__c orgDefaults = LoggerSettings__c.getOrgDefaults();
        if (orgDefaults.Id == null) {
            insert orgDefaults;
        }
    }

    // Settings management methods
    global static String getTransactionId() {
        return TRANSACTION_ID;
    }

    global static void setParentLogTransactionId(String transactionId) {
        parentLogTransactionId = transactionId;
    }

    global static String getParentLogTransactionId() {
        return parentLogTransactionId;
    }

    global static LoggingLevel getUserLoggingLevel() {
        return USER_LOGGING_LEVEL;
    }

    global static Quiddity getCurrentQuiddity() {
        return transactionSaveMethod;
    }

    global static Boolean isEnabled() {
        return LoggerSettings__c.getInstance().IsEnabled__c;
    }

    global static Boolean isEnabled(LoggingLevel loggingLevel) {
        return isEnabled() && meetsUserLoggingLevel(loggingLevel);
    }

    global static Boolean isErrorEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.ERROR);
    }

    global static Boolean isWarnEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.WARN);
    }

    global static Boolean isInfoEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.INFO);
    }

    global static Boolean isDebugEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.DEBUG);
    }

    global static Boolean isFineEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.FINE);
    }

    global static Boolean isFinerEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.FINER);
    }

    global static Boolean isFinestEnabled() {
        return isEnabled() && meetsUserLoggingLevel(LoggingLevel.FINEST);
    }

    global static Boolean meetsUserLoggingLevel(LoggingLevel logEntryLoggingLevel) {
        return USER_LOGGING_LEVEL.ordinal() <= logEntryLoggingLevel.ordinal();
    }

    // Transaction control methods
    global static Boolean isSavingSuspended() {
        return suspendSaving;
    }

    global static void suspendSaving() {
        suspendSaving = true;
    }

    global static void resumeSaving() {
        suspendSaving = false;
    }

    global static Integer getBufferSize() {
        return LOG_ENTRIES.size();
    }

    global static void flushBuffer() {
        LOG_ENTRIES.clear();
    }

    // ERROR logging level methods
    global static LogEntryEventBuilder error() {
        return createLogEntryEventBuilder(LoggingLevel.ERROR);
    }

    global static LogEntryEventBuilder error(String message) {
        return error().setMessage(message);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage) {
        return error().setMessage(logMessage);
    }

    global static LogEntryEventBuilder error(String message, List<String> topics) {
        return error().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, List<String> topics) {
        return error().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder error(String message, SObject record) {
        return error().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, SObject record) {
        return error().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder error(String message, SObject record, List<String> topics) {
        return error().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, SObject record, List<String> topics) {
        return error().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder error(String message, Id recordId) {
        return error().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, Id recordId) {
        return error().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder error(String message, Id recordId, List<String> topics) {
        return error().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, Id recordId, List<String> topics) {
        return error().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder error(String message, Exception apexException) {
        return error().setMessage(message).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, Exception apexException) {
        return error().setMessage(logMessage).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(String message, Exception apexException, List<String> topics) {
        return error().setMessage(message).setTopics(topics).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, Exception apexException, List<String> topics) {
        return error().setMessage(logMessage).setTopics(topics).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(String message, SObject record, Exception apexException) {
        return error().setMessage(message).setRecordId(record).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, SObject record, Exception apexException) {
        return error().setMessage(logMessage).setRecordId(record).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(
        String message,
        SObject record,
        Exception apexException,
        List<String> topics
    ) {
        return error().setMessage(message).setRecordId(record).setTopics(topics).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(
        LogMessage logMessage,
        SObject record,
        Exception apexException,
        List<String> topics
    ) {
        return error().setMessage(logMessage).setRecordId(record).setTopics(topics).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(String message, Id recordId, Exception apexException) {
        return error().setMessage(message).setRecordId(recordId).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(LogMessage logMessage, Id recordId, Exception apexException) {
        return error().setMessage(logMessage).setRecordId(recordId).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(
        String message,
        Id recordId,
        Exception apexException,
        List<String> topics
    ) {
        return error().setMessage(message).setRecordId(recordId).setTopics(topics).setExceptionDetails(apexException);
    }

    global static LogEntryEventBuilder error(
        LogMessage logMessage,
        Id recordId,
        Exception apexException,
        List<String> topics
    ) {
        return error()
            .setMessage(logMessage)
            .setRecordId(recordId)
            .setTopics(topics)
            .setExceptionDetails(apexException);
    }

    // WARN logging level methods
    global static LogEntryEventBuilder warn() {
        return createLogEntryEventBuilder(LoggingLevel.WARN);
    }

    global static LogEntryEventBuilder warn(String message) {
        return warn().setMessage(message);
    }

    global static LogEntryEventBuilder warn(LogMessage logMessage) {
        return warn().setMessage(logMessage);
    }

    global static LogEntryEventBuilder warn(String message, List<String> topics) {
        return warn().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder warn(LogMessage logMessage, List<String> topics) {
        return warn().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder warn(String message, SObject record) {
        return warn().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder warn(LogMessage logMessage, SObject record) {
        return warn().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder warn(String message, SObject record, List<String> topics) {
        return warn().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder warn(LogMessage logMessage, SObject record, List<String> topics) {
        return warn().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder warn(String message, Id recordId) {
        return warn().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder warn(LogMessage logMessage, Id recordId) {
        return warn().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder warn(String message, Id recordId, List<String> topics) {
        return warn().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder warn(LogMessage logMessage, Id recordId, List<String> topics) {
        return warn().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    // INFO logging level methods
    global static LogEntryEventBuilder info() {
        return createLogEntryEventBuilder(LoggingLevel.INFO);
    }

    global static LogEntryEventBuilder info(String message) {
        return info().setMessage(message);
    }

    global static LogEntryEventBuilder info(LogMessage logMessage) {
        return info().setMessage(logMessage);
    }

    global static LogEntryEventBuilder info(String message, List<String> topics) {
        return info().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder info(LogMessage logMessage, List<String> topics) {
        return info().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder info(String message, SObject record) {
        return info().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder info(LogMessage logMessage, SObject record) {
        return info().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder info(String message, SObject record, List<String> topics) {
        return info().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder info(LogMessage logMessage, SObject record, List<String> topics) {
        return info().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder info(String message, Id recordId) {
        return info().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder info(LogMessage logMessage, Id recordId) {
        return info().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder info(String message, Id recordId, List<String> topics) {
        return info().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder info(LogMessage logMessage, Id recordId, List<String> topics) {
        return info().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    // DEBUG log level methods
    global static LogEntryEventBuilder debug() {
        return createLogEntryEventBuilder(LoggingLevel.DEBUG);
    }

    global static LogEntryEventBuilder debug(String message) {
        return debug().setMessage(message);
    }

    global static LogEntryEventBuilder debug(LogMessage logMessage) {
        return debug().setMessage(logMessage);
    }

    global static LogEntryEventBuilder debug(String message, List<String> topics) {
        return debug().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder debug(LogMessage logMessage, List<String> topics) {
        return debug().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder debug(String message, SObject record) {
        return debug().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder debug(LogMessage logMessage, SObject record) {
        return debug().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder debug(String message, SObject record, List<String> topics) {
        return debug().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder debug(LogMessage logMessage, SObject record, List<String> topics) {
        return debug().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder debug(String message, Id recordId) {
        return debug().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder debug(LogMessage logMessage, Id recordId) {
        return debug().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder debug(String message, Id recordId, List<String> topics) {
        return debug().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder debug(LogMessage logMessage, Id recordId, List<String> topics) {
        return debug().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    // FINE log level methods
    global static LogEntryEventBuilder fine() {
        return createLogEntryEventBuilder(LoggingLevel.FINE);
    }

    global static LogEntryEventBuilder fine(String message) {
        return fine().setMessage(message);
    }

    global static LogEntryEventBuilder fine(LogMessage logMessage) {
        return fine().setMessage(logMessage);
    }

    global static LogEntryEventBuilder fine(String message, List<String> topics) {
        return fine().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder fine(LogMessage logMessage, List<String> topics) {
        return fine().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder fine(String message, SObject record) {
        return fine().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder fine(LogMessage logMessage, SObject record) {
        return fine().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder fine(String message, SObject record, List<String> topics) {
        return fine().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder fine(LogMessage logMessage, SObject record, List<String> topics) {
        return fine().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder fine(String message, Id recordId) {
        return fine().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder fine(LogMessage logMessage, Id recordId) {
        return fine().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder fine(String message, Id recordId, List<String> topics) {
        return fine().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder fine(LogMessage logMessage, Id recordId, List<String> topics) {
        return fine().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    // FINER log level methods
    global static LogEntryEventBuilder finer() {
        return createLogEntryEventBuilder(LoggingLevel.FINER);
    }

    global static LogEntryEventBuilder finer(String message) {
        return finer().setMessage(message);
    }

    global static LogEntryEventBuilder finer(LogMessage logMessage) {
        return finer().setMessage(logMessage);
    }

    global static LogEntryEventBuilder finer(String message, List<String> topics) {
        return finer().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder finer(LogMessage logMessage, List<String> topics) {
        return finer().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder finer(String message, SObject record) {
        return finer().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder finer(LogMessage logMessage, SObject record) {
        return finer().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder finer(String message, SObject record, List<String> topics) {
        return finer().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder finer(LogMessage logMessage, SObject record, List<String> topics) {
        return finer().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder finer(String message, Id recordId) {
        return finer().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder finer(LogMessage logMessage, Id recordId) {
        return finer().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder finer(String message, Id recordId, List<String> topics) {
        return finer().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder finer(LogMessage logMessage, Id recordId, List<String> topics) {
        return finer().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    // FINEST log level methods
    global static LogEntryEventBuilder finest() {
        return createLogEntryEventBuilder(LoggingLevel.FINEST);
    }

    global static LogEntryEventBuilder finest(String message) {
        return finest().setMessage(message);
    }

    global static LogEntryEventBuilder finest(LogMessage logMessage) {
        return finest().setMessage(logMessage);
    }

    global static LogEntryEventBuilder finest(String message, List<String> topics) {
        return finest().setMessage(message).setTopics(topics);
    }

    global static LogEntryEventBuilder finest(LogMessage logMessage, List<String> topics) {
        return finest().setMessage(logMessage).setTopics(topics);
    }

    global static LogEntryEventBuilder finest(String message, SObject record) {
        return finest().setMessage(message).setRecordId(record);
    }

    global static LogEntryEventBuilder finest(LogMessage logMessage, SObject record) {
        return finest().setMessage(logMessage).setRecordId(record);
    }

    global static LogEntryEventBuilder finest(String message, SObject record, List<String> topics) {
        return finest().setMessage(message).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder finest(LogMessage logMessage, SObject record, List<String> topics) {
        return finest().setMessage(logMessage).setRecordId(record).setTopics(topics);
    }

    global static LogEntryEventBuilder finest(String message, Id recordId) {
        return finest().setMessage(message).setRecordId(recordId);
    }

    global static LogEntryEventBuilder finest(LogMessage logMessage, Id recordId) {
        return finest().setMessage(logMessage).setRecordId(recordId);
    }

    global static LogEntryEventBuilder finest(String message, Id recordId, List<String> topics) {
        return finest().setMessage(message).setRecordId(recordId).setTopics(topics);
    }

    global static LogEntryEventBuilder finest(LogMessage logMessage, Id recordId, List<String> topics) {
        return finest().setMessage(logMessage).setRecordId(recordId).setTopics(topics);
    }

    global static void setSaveMethod(Quiddity quiddity) {
        transactionSaveMethod = quiddity;
    }

    @InvocableMethod(category='Logging' label='Save Log' description='Saves any log entries that have been generated')
    global static void saveLog() {
        saveLog(transactionSaveMethod);
    }

    global static void saveLog(Quiddity quiddity) {
        if (LOG_ENTRIES.isEmpty()) {
            return;
        }

        Boolean systemMessagesEnabled = LoggerSettings__c.getInstance().EnableSystemMessages__c;

        if (suspendSaving) {
            if (systemMessagesEnabled) {
                String suspendSavingLogMessage = 'Logging suspended, ignoring call to saveLog()';
                finest(suspendSavingLogMessage);
            }

            return;
        }

        if (systemMessagesEnabled) {
            String savingLogMessage = 'Saving ' + LOG_ENTRIES.size() + ' log entries via ';
            switch on quiddity {
                when ANONYMOUS {
                    savingLogMessage += 'Anonymous Apex';
                }
                when Aura, VF {
                    savingLogMessage += 'Aura/Lightning/VF component';
                }
                when BATCH_ACS, BATCH_APEX, BATCH_CHUNK_PARALLEL, BATCH_CHUNK_SERIAL {
                    savingLogMessage += 'Apex batch job';
                }
                when INVOCABLE_ACTION {
                    savingLogMessage += 'Flow invocation';
                }
                when QUEUEABLE {
                    savingLogMessage += 'Apex queueable job';
                }
                when REST {
                    savingLogMessage += 'Apex REST callout';
                }
                when SCHEDULED {
                    savingLogMessage += 'Scheduled job';
                }
                when SYNCHRONOUS {
                    savingLogMessage += 'Apex synchronous DML';
                }
                when else {
                    savingLogMessage += quiddity.name();
                }
            }
            finest(savingLogMessage);
        }

        // TODO cleanup
        List<LogEntryEventBuilder> logEntriesToSave = new List<LogEntryEventBuilder>();
        for (LogEntryEventBuilder logEntryBuilder : LOG_ENTRIES) {
            if (!logEntryBuilder.shouldSave()) {
                continue;
            }

            logEntriesToSave.add(logEntryBuilder);
        }
        flushBuffer();
        LOG_ENTRIES.addAll(logEntriesToSave);

        List<LogEntryEvent__e> logEntryEvents = new List<LogEntryEvent__e>();
        Integer indexOfLastRecord = LOG_ENTRIES.size() - 1;
        for (Integer i = 0; i < LOG_ENTRIES.size(); i++) {
            LogEntryEventBuilder logEntryBuilder = LOG_ENTRIES.get(i);

            if (i == indexOfLastRecord) {
                logEntryBuilder.setUserSessionDetails();
            }

            LogEntryEvent__e logEntryEvent = logEntryBuilder.getLogEntryEvent();
            logEntryEvent.ParentLogTransactionId__c = getParentLogTransactionId();
            logEntryEvent.SystemMode__c = getCurrentQuiddity().name();
            logEntryEvent.TransactionId__c = getTransactionId();
            logEntryEvents.add(logEntryEvent);
        }

        switch on quiddity {
            when QUEUEABLE {
                ASYNC_SAVER_INSTANCE.enqueueLogEntries(logEntryEvents);
            }
            when REST {
                RestApi.insertRecords(logEntryEvents);
            }
            when else {
                List<Database.SaveResult> results = EventBus.publish(logEntryEvents);
                System.debug('saveResults =' + results);
            }
        }

        // TODO add error handling for when event bus fails to publish
        flushBuffer();
    }

    // Utility methods
    global static LoggingLevel getLoggingLevel(String loggingLevelName) {
        if (loggingLevelName != null) {
            loggingLevelName = loggingLevelName.toUpperCase();
        }

        switch on loggingLevelName {
            when 'NONE' {
                return LoggingLevel.NONE;
            }
            when 'ERROR' {
                return LoggingLevel.ERROR;
            }
            when 'WARN' {
                return LoggingLevel.WARN;
            }
            when 'INFO' {
                return LoggingLevel.INFO;
            }
            when 'DEBUG' {
                return LoggingLevel.DEBUG;
            }
            when 'FINE' {
                return LoggingLevel.FINE;
            }
            when 'FINER' {
                return LoggingLevel.FINER;
            }
            when 'FINEST' {
                return LoggingLevel.FINEST;
            }
            when else {
                LoggingLevel fallbackLevel = LoggingLevel.DEBUG;
                String message =
                    'Unknown logging level ' +
                    loggingLevelName +
                    'specified, using ' +
                    fallbackLevel.Name();
                finest(message);
                return LoggingLevel.DEBUG;
            }
        }
    }

    public static LogEntryEventBuilder createLogEntryEventBuilder(LoggingLevel loggingLevel) {
        LogEntryEventBuilder logEntryBuilder = new LogEntryEventBuilder(LoggingLevel);
        LOG_ENTRIES.add(logEntryBuilder);

        return logEntryBuilder;
    }

    @AuraEnabled
    public static Log__c getLog(Id logId) {
        List<String> logFieldNames = new List<String>(Schema.Log__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> logEntryFieldNames = new List<String>(
            Schema.LogEntry__c.SObjectType.getDescribe().fields.getMap().keySet()
        );

        List<String> textReplacements = new List<String>{
            String.join(logFieldNames, ','),
            String.join(logEntryFieldNames, ',')
        };
        String query = String.format(
            'SELECT {0}, (SELECT {1} FROM LogEntries__r) FROM Log__c WHERE Id = :logId',
            textReplacements
        );

        return (Log__c) Database.query(query);
    }

    // Inner class for saving log entries via a queuable job (using a singleton pattern)
    global class QueueableSaver implements Queueable {
        private Id jobId;

        private List<LogEntryEvent__e> logEntryEvents = new List<LogEntryEvent__e>();

        global void enqueueLogEntries(List<LogEntryEvent__e> logEntryEvents) {
            this.logEntryEvents.addAll(logEntryEvents);

            if (jobId == null) {
                jobId = System.enqueueJob(this);
            }
        }

        global void execute(System.QueueableContext queueableContext) {
            EventBus.publish(this.logEntryEvents);
        }
    }
}