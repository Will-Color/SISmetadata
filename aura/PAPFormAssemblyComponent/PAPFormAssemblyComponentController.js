({
    getUserDataCall : function(component, event, helper) {
        
        var url = '';
        var userDataList = [];
        var recordId =component.get("v.recordId");
        //'a1311000005lUdRAAU';
        var papStat;
        var supStat;
        var action = component.get("c.getUserData");
        action.setParams({ recId : recordId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                userDataList = response.getReturnValue();
                //console.log(userDataList);
                var dataList = userDataList[0];
                var urlPara ='';
                for (key in dataList){
                    //console.log("dataList["+ key +"]="+ dataList[key]);
                    if(key == 'User_is_PAP_Member__c'){
                        papStat = dataList[key];
                    }
                    if(key == 'User_is_Supervisor__c'){
                        supStat = dataList[key];
                    }
                }
                if(papStat == true){
                    urlPara = '&tfa_129=TRUE';
                }
                else if(supStat == true){
                    urlPara = '&tfa_128=TRUE';
                }
                else{
                    urlPara = '&tfa_12';
                }
                //console.log(papStat);
                //console.log(supStat);
                url = 'https://color.tfaforms.net/54?PAID='+recordId+urlPara;//&tfa_128='+supStat;//+'&tfa_129='+papStat
                component.set("v.urlTag",url);
                //alert(url);
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