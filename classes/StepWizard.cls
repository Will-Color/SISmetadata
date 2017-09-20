/**
 * @author Mykola Senyk
 * @date 10/07/2014
 * @description Class to hold information about step of wizard
 */
public class StepWizard {

    private List<String> stepsList;
    private Map<String,String> stepTitles;
    
    public StepWizard(Integer index, List<String> sList, Map<String,String> mapTitles) {
        stepIndex = index;
        stepsList = sList;
        stepTitles = mapTitles;
    }

    public Integer stepIndex { get; set; }

    public Boolean hasNextStep { get {
            return stepIndex < stepsList.size() - 1;
        }
    }

    public Boolean hasPreviousStep { get {
            return stepIndex > 0;
        }
    }

    public Boolean gotoStepByName(String stepName) {
        Boolean res = false;
        for(Integer i=0; i<stepsList.size(); i++) {
            if ( stepsList[i].equals(stepName) ) {
                stepIndex = i;
                res = true;
                break;
            }
        }
        return res;
    }

    public String getName() {
        return stepsList[stepIndex];
    }

    public String getTitle() {
        return stepTitles.get(getName());
    }
}