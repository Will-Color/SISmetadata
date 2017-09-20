({
    getUserDataCall2 : function(component, event, helper) {
        console.log('c');
        var url = '';
        var studId = '';
        var userDataList = [];
        var recordId =component.get("v.recordId");
        var action = component.get("c.getUserDataStd");
        action.setParams({ 
            recId : recordId 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                userDataList = response.getReturnValue();
                
                var dataList = userDataList[0];
                for (key in dataList){
                    //console.log("dataList["+ key +"]="+ dataList[key]);
                    if(key == 'Student__c'){
                        studId = dataList[key];
                    }
                }
                url = 'https://color.tfaforms.net/56?SPID='+recordId+'&StudentID='+studId;
                component.set("v.urlTag",url);
               // console.log(url);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})