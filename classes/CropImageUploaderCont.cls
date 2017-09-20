/**
 * @author Mykola Senyk
 * @date 08/07/2014
 * @description Controller for CropImageUploader component
 * @ modifications
 * @author Maneesh M
 * @date 1-sep-205
 * @description Edited size of the saving imgae into 35mm*45mm and saved this as chatter profilr pic
 * @author Manu K M
 * @date 29-sep-205
 * @description Edited name of the saving imgae into lstm number (without 0 prefixes)
 */
 
public without sharing class CropImageUploaderCont {

    // Filename for attachment
    public static final String FILENAME_OF_PHOTO = '1234.jpg';    
    public Id attParentId { get; set; }
    public String attDescription { get; set; }
    public String imageBody { get; set; }
    
    public CropImageUploaderCont() {}       
    /**
     * Action for upload image into attachment
     */
     @future
     public static void setprofpic(String communityid, String userid,Blob image)
     {
         ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(image, 'text', 'profilepic.jpg');   
         if(!Test.isRunningTest()){
     
          ConnectApi.ChatterUsers.setPhoto(communityid, userid ,  new ConnectApi.BinaryInput(image,'image/jpg','userImage.jpg')); 
          }
     }
    public void uploadImage() {
        
        String LstmImageName = '';
        System.Debug('attParentId in fileupload '+ attParentId );
        //System.Debug('test:'+ [SELECT Id, LSTM_No__c FROM Student_Programme__c where id =:attParentId Limit 1]);
        Student_Programme__c lstmName = [SELECT Id, LSTM_No__c,New_Upload__c FROM Student_Programme__c where id =:attParentId Limit 1];
        if(lstmName.LSTM_No__c != null){
            string s = lstmName.LSTM_No__c ;
            string[] arrayOfLstmNumber = lstmName.LSTM_No__c.split('');           
            integer i;                    
            for(i = 0;i<arrayOfLstmNumber.size();i++)
            {                        
                    if(arrayOfLstmNumber[i]!= '0' ){
                        LstmImageName = LstmImageName + arrayOfLstmNumber[i];                                 
                    }
                    else if(LstmImageName != ''){
                       LstmImageName = LstmImageName + arrayOfLstmNumber[i];  
                    }           
            } 
        } 
        if(LstmImageName == '')
        {
            LstmImageName = '000.jpg'; 
        }else{     
            LstmImageName = LstmImageName +'.jpg';
        }        
        Attachment a = new Attachment(ParentId = attParentId, Description = attDescription, Name = LstmImageName );
        if ( !String.isBlank(imageBody) ) {
            try {
                // remove existing attachment
                List<Attachment> existAtts = CommonUtils.findAttachments(attParentId, attDescription);
                delete existAtts;
                a.Body = EncodingUtil.base64Decode(imageBody);
                List<Network> customCommunity = [SELECT id, name FROM Network where Name='LSTM Community'];
                String communityId = customCommunity[0].Id;                                                                     
                insert a;
                //Suyati Modified 27-04-2016
                 //Student_Programme__c sp = [SELECT Id,New_Upload__c FROM Student_Programme__c WHERE Id =: attParentId];
                 lstmName.New_Upload__c = true;
                 System.debug('before update');
                 UPDATE lstmName ;
                 //Suyati Modified End 27-04-2016
                setprofpic(Network.getNetworkId(), UserInfo.getUserId(),a.body);               
            }           
            finally {
               imageBody = null;
           }
        }
    }
    
}