/**
 * @author Mykola Senyk
 * @date 10/07/2014
 * @description Unit test for StepWizard class
 */
@isTest
private class TestStepWizard {

    static testMethod void test() {
        String stepOne = 'one', stepTwo = 'two', stepMiddle = 'middle', stepLast = 'last';
        List<String> steps = new List<String> { stepOne, stepTwo, stepMiddle, stepLast};
        Map<String,String> titles = new Map<String,String> {
            stepOne => 'One title', stepTwo => 'Two title', stepMiddle => 'Middle title', stepLast => 'Last title'
        };
        
        // first step
        Integer stepIndex = 0;
        StepWizard s = new StepWizard(stepIndex, steps, titles);
        System.assert(!s.hasPreviousStep);
        System.assert(s.hasNextStep);
        System.assertEquals(stepOne, s.getName());
        System.assertEquals(titles.get(stepOne), s.getTitle());
        
        // step in the middle
        stepIndex = 2;
        s = new StepWizard(stepIndex, steps, titles);
        System.assert(s.hasPreviousStep);
        System.assert(s.hasNextStep);
        System.assertEquals(stepMiddle, s.getName());
        System.assertEquals(titles.get(stepMiddle), s.getTitle());
        
        // goto step
        s.gotoStepByName(stepTwo);
        System.assert(s.hasPreviousStep);
        System.assert(s.hasNextStep);
        System.assertEquals(stepTwo, s.getName());
        System.assertEquals(titles.get(stepTwo), s.getTitle());
        
        // last step
        stepIndex = steps.size()-1;
        s = new StepWizard(stepIndex, steps, titles);
        System.assert(s.hasPreviousStep);
        System.assert(!s.hasNextStep);
        System.assertEquals(stepLast, s.getName());
        System.assertEquals(titles.get(stepLast), s.getTitle());
    }
    
}