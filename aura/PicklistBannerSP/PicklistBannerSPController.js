({
    doInit: function(component, event, helper) {
        
        var action = component.get("c.getCompletedStages");
        
        action.setParams({
            "studenProgrammeId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.completedList", response.getReturnValue());
            }
            else {
            }
        });
        
        $A.enqueueAction(action);
        
        var action2 = component.get("c.getFutureStages");
        
        action2.setParams({
            "studenProgrammeId": component.get("v.recordId")
        });
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.incompleteList", response.getReturnValue());
            }
            else {
            }
        });
        
        $A.enqueueAction(action2);        
        
        var action3 = component.get("c.getCurrentStage");
        
        action3.setParams({
            "studenProgrammeId": component.get("v.recordId")
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.currentStage", response.getReturnValue());
            }
            else {
            }
        });
        
        $A.enqueueAction(action3);                
    },
    
    jsClick: function(component, event, helper) {
        document.addEventListener('click', function(e) {
            var idClicked = e.target.id;
            var futureStages = component.get("v.incompleteList");
            var currentStage = component.get("v.currentStage");
            var finishedStages = component.get("v.completedList");            
            if(idClicked === currentStage || futureStages.includes(idClicked) || finishedStages.includes(idClicked) )
            {   
                var conf = confirm("This will update the stage. Are you sure you want to continue?");
                if(conf === true){   
                    var updateAction = component.get("c.updateStage");
                    updateAction.setParams({"studenProgrammeId": component.get("v.recordId"), "stageName": idClicked});
                    
                    updateAction.setCallback(this, function(response) {
                        var updateState = response.getState();
                        if (component.isValid() && updateState === "SUCCESS") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "The stage has been updated successfully.",
                            });
                            toastEvent.fire();
                        }
                        else {
                        }
                    }); 
                    $A.enqueueAction(updateAction);
                    $A.get('e.force:refreshView').fire();              
                }
            }
        });      	
    }    
})