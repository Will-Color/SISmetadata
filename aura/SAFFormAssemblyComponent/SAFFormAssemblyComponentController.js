({
	getUserIdCall : function(component, event, helper) {
        var userlist = [];
        var userId = '';
        var conId = '';
        var recordId =component.get("v.recordId");
        var action = component.get("c.getUserId");        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log(state);
            if (state === "SUCCESS") {
                userlist = response.getReturnValue();
                var tList = userlist[0];
                //var urlPara ='&PSID='+userId;
                //console.log(userlist[0]);
                for (key in tList){
                    //console.log(key);
                    if(key == 'Id'){
                        //console.log(key);
                        userId = tList[key];
                    }
                    if(key == 'ContactId'){
                        //console.log(key);
                        conId = tList[key];
                    }
                }
                var url = 'https://color.tfaforms.net/55?SPID='+recordId+'&PSID='+conId+'&tfa_222='+conId;
                //console.log(url);
                component.set("v.urlTag",url);           
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