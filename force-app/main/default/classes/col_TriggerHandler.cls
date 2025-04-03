/**
 * ===================================================================
 * 
 * @author      
 * @email       
 * @version     
 * @date        
 * @description 
 * ===================================================================
**/
public virtual class col_TriggerHandler {

    // The current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // The current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
      
    // Constructor
    public col_TriggerHandler() {
		this.setTriggerContext();
    }

    /***************************************
     * Public instance methods
     ***************************************/

    // Main method that will be called during execution
    public void run() {

		if(!isTriggerToRun()) {
			return;
		}
		// Dispatch to the correct handler method
		switch on this.context {
			when BEFORE_INSERT {
				this.onBeforeInsert();
			}
			when BEFORE_UPDATE {
				this.onBeforeUpdate();
			}
			when BEFORE_DELETE {
				this.onBeforeDelete();
			}
			when AFTER_INSERT {
				this.onAfterInsert();
			}
			when AFTER_UPDATE {
				this.onAfterUpdate();
			}
			when AFTER_DELETE {
				this.onAfterDelete();
			}
			when AFTER_UNDELETE {
				this.onAfterUndelete();
			}
		}
    }

    /***************************************
     * Private instance methods
     ***************************************/

    @TestVisible
    private void setTriggerContext() {
      this.setTriggerContext(null, false);
    }

    @TestVisible
	private void setTriggerContext(String ctx, Boolean testMode) {
		if(!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}
		
		if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
			(ctx != null && ctx == 'before insert')) {
			this.context = TriggerContext.BEFORE_INSERT;
		} else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
			(ctx != null && ctx == 'before update')){
			this.context = TriggerContext.BEFORE_UPDATE;
		} else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
			(ctx != null && ctx == 'before delete')) {
			this.context = TriggerContext.BEFORE_DELETE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
			(ctx != null && ctx == 'after insert')) {
			this.context = TriggerContext.AFTER_INSERT;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
			(ctx != null && ctx == 'after update')) {
			this.context = TriggerContext.AFTER_UPDATE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
			(ctx != null && ctx == 'after delete')) {
			this.context = TriggerContext.AFTER_DELETE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
			(ctx != null && ctx == 'after undelete')) {
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

    /** 
	* @description 	Check if the trigger should continue to run
	* @return 		true	-> the Apex Trigger Handler shall run
	* @return		false	-> the Apex Trigger handler shall not run
	*/
    @TestVisible
    private Boolean isTriggerToRun() {
		if(!this.isTriggerExecuting || this.context == null) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}
		Boolean isBypassApexTrigger = FeatureManagement.checkPermission('isBypassApexTrigger');
		return !isBypassApexTrigger;
    }


    @TestVisible
    private String getHandlerName() {
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    /***************************************
     * Context methods
     ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void onBeforeInsert(){}
    @TestVisible
    protected virtual void onBeforeUpdate(){}
    @TestVisible
    protected virtual void onBeforeDelete(){}
    @TestVisible
    protected virtual void onAfterInsert(){}
    @TestVisible
    protected virtual void onAfterUpdate(){}
    @TestVisible
    protected virtual void onAfterDelete(){}
    @TestVisible
    protected virtual void onAfterUndelete(){}

    // Possible trigger contexts
    @TestVisible
    private enum TriggerContext {
		BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
		AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
		AFTER_UNDELETE
    }

    // Exception class
    public class TriggerHandlerException extends Exception {}
}