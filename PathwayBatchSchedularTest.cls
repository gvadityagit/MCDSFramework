@isTest
public class PathwayBatchSchedularTest { 
@testSetup static void setupTestData(){
        TestClassDataFactory.loadCustomSettings();
    }
    static testMethod void testmethod1() {
      Test.startTest();
        PathwayBatchSchedular scheduler = new PathwayBatchSchedular('AnnualMedReviewBatch' ,200);
        system.schedule('pathwaySchduler', '0 0 0 3 9 ? 2022', scheduler);
        Test.stopTest();
        system.assertNotEquals(scheduler,null);
        system.assertEquals(scheduler.batchName,'AnnualMedReviewBatch');
    }
}