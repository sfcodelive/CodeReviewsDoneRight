@isTest
private class PartnerAgreement_test {
	
	@testsetup static void createTestData(){
		double vrandom = math.random();
		list<Partner_Agreement_Healthcare_Specialist__c> lPAHS = new list<Partner_Agreement_Healthcare_Specialist__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='teststandarduser@testorg.combetterpartners'+vrandom, 
        EmailEncodingKey='UTF-8', LastName='Testing', Firstname='Tester', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@testorg.combetterpartners'+vrandom);
        insert u;	

		User testUser = [select Name, Email, UserName from User where isActive =true and lastname = 'testing' and firstname='tester' limit 1];
		
		lPAHs.add(new Partner_Agreement_Healthcare_Specialist__c(
			Name = testUser.Name,
			Specialist_s_Email__c = testUser.Email
		));
		lPAHS.add(new Partner_Agreement_Healthcare_Specialist__c(
			Name = 'George Wilson',
			Specialist_s_Email__c = 'gwilson@wizardcast.com.test'
		));
		lPAHS.add(new Partner_Agreement_Healthcare_Specialist__c(
			Name = 'Peter Wilson',
			Specialist_s_Email__c = 'pwilson@wizardcast.com.test'
		));
		lPAHS.add(new Partner_Agreement_Healthcare_Specialist__c(
			Name = 'Ryan Wilson',
			Specialist_s_Email__c = 'rwilson@wizardcast.com.test'
		));		
		insert lPAHS;
		
		Account Facility = new account(name='Facility');
		Account Distributor = new ACcount(name='Distributor');
		
		list<Account> lActs = new list<Account>();
		lActs.add(facility); lActs.add(Distributor);
		insert lacts;
		Contact Con = new Contact(firstName='PATest', 
		LastName='Contact', AccountID=Facility.id);
		insert con;

		Partner_Agreement__c testPA = new Partner_Agreement__c(
			Agreement_Type__c = 'TestData',
			Sales_Rep_Comments__c = 'Test PA',
			Sales_Rep_Company__c = 'MK FOOD SERVICE EQPT,INC',
			Sales_Rep_Email__c = 'support+Salestest@betterpartners.com',
			Sales_Rep_Name__c = 'Better Partners',
			City__c = 'York',
			Customer_Email__c = 'support+Salestest1@betterpartners.com',
			Customer_Fax__c = 'n/a',
			Customer_Name__c = 'Better Partners Name',
			Customer_Phone__c = '(717) 840-7100',
			Customer_Title__c = 'Corporate Buyer',
			Distributor_City__c = 'Alletnown',
			Distributor_Name__c = 'US Foods',
			Distributor_Sales_Rep_E_mail__c = 'support+Salestest2@betterpartners.com',
			Distributor_State__c = 'PA',
			Distributor_Zip_Code__c = '18109',
			Distributor_Street_Address__c = '1200 Hoover Ave.',
			Facility_Name__c = 'Pleasant Acres Nursing & Rehab.',
			Healthcare_Specialist__c = testUser.id,
			Licensed_Beds__c = 378,
			Order_Number__c = '19062122-0',			
			Renewal__c = 'No',
			Room_Trays_Served__c = 378,
			Status__c = 'Shipped',
			State__c = 'PA',
			Street_Address__c = '118 Pleasant Acres Rd.',
			Zip_Postal_Code__c = '17402',
			Start_Date__c = date.today()-366,
			End_Date__c = date.today()-1,
			Facility__c = Distributor.id,
			Distributor__c = Facility.id,
			Contact__c = Con.id
		);
		insert testPa;
	} 

	@isTest static void test_CMDT_Submit(){

		Partner_Agreement__c PA = new Partner_Agreement__c();
        PageReference pageRef = Page.PartnerAgreements;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(PA);
        PartnerAgreement_ext ext =  new PartnerAgreement_ext(sc);
		
		User testUser = [select id,Name, Email, UserName from User where isActive =true and lastname = 'testing' and firstname='tester' limit 1];

		ext.getvSpecialists();
        //ext.MyAgreement.Agreement_Type__c = 'Mugs & Bowls';
		ext.MyAgreement.Agreement_Type__c = 'TestData';
        ext.RefreshProds(); //calls FieldVisibilityControl()
       // ext.queryHealthcareSpecialist(); //Called by Submit()

        ext.vSpecialist = testUser.UserName;   //set the HealthSpecialist      
        
        //ext.getvAgreementTypes();
        
        ext.SumbitEmailRep(); //Calls Submit()
		//PrdColors test input
        test.starttest();
        try{
          Partner_Agreement__c vPA = [select id from Partner_Agreement__c limit 1];
          list<Partner_Agreement_Product__c> lPAProds = [select id from Partner_Agreement_Product__c where Partner_Agreement__c= :vPA.id Order by Code__c];
          for(integer i=0; i<lPAProds.size(); i++){
            system.assertequals(lPAProds[i].Code__c,'TestProduct'+i+1);
          }        	
        }catch(exception e){
          system.debug('Error: ' + e);
        }

        test.stoptest();        

	}
	@isTest static void test_CMDT_Other(){

		Partner_Agreement__c PA = new Partner_Agreement__c();
        PageReference pageRef = Page.PartnerAgreements;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(PA);
        PartnerAgreement_ext ext =  new PartnerAgreement_ext(sc);
		
		User testUser = [select id,Name, Email, UserName from User where isActive =true and lastname = 'testing' and firstname='tester' limit 1];

		ext.getvSpecialists();
        //ext.MyAgreement.Agreement_Type__c = 'Mugs & Bowls';
		ext.MyAgreement.Agreement_Type__c = 'TestData';
        ext.RefreshProds(); //calls FieldVisibilityControl()

		//PrdColors test input
		list<SelectOption> options = ext.getvSpecialists();
        test.starttest();
        	//ext.getRepGroups();
          map<string,Partner_Agreement_Healthcare_Specialist__c> mSpecialists = Partner_Agreement_Healthcare_Specialist__c.getAll();		    

          system.assertnotequals(null,options,'Options should be instantiated');
          system.assert(!options.isEmpty(),'Options should be populated');
          string vlabel;
          for(integer i=0; i<options.size(); i++){
          vlabel = options.get(i).getvalue();
          system.assertnotequals(null, vlabel,'Label shouldnt be empty');
          if(vlabel == 'gwilson@WizardCast.com.test'
            || vlabel =='pwilson@WizardCast.com.test'
            || vlabel =='rwilson@WizardCast.com.test'|| vlabel == testUser.email 
            ||  vlabel =='--none--' || vlabel == ''){

            }else{
              system.assert(false,vlabel +' HealthSpecialst does not match custom setting values');
            }
          }
        ext.vSpecialist = testUser.Email;
        string vUserID = ext.queryHealthcareSpecialist();
        system.assertequals(vUserID,testUser.id);
        test.stoptest();   

	}
	@isTest static void test_CMDT_Coverage(){

		Partner_Agreement__c PA = new Partner_Agreement__c();
        PageReference pageRef = Page.PartnerAgreements;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(PA);
        PartnerAgreement_ext ext =  new PartnerAgreement_ext(sc);
		
		User testUser = [select id,Name, Email, UserName from User where isActive =true and lastname = 'testing' and firstname='tester' limit 1];

		ext.getvSpecialists();
        //ext.MyAgreement.Agreement_Type__c = 'Mugs & Bowls';
		ext.MyAgreement.Agreement_Type__c = 'TestData';
    ext.RefreshProds(); 
    ext.vSpecialist = testUser.UserName;   //set the HealthSpecialist      
    ext.MyAgreement.Agreement_Type__c = 'Mugs';
    ext.FieldVisibilityControl();       
    system.assertequals(true,ext.DisplayDiameter );
    ext.MyAgreement.Agreement_Type__c = 'Tumblers';
    ext.FieldVisibilityControl();
    system.assertequals(true,ext.DisplayDisposableLidCode );
    ext.MyAgreement.Agreement_Type__c = 'Camlids';
    ext.FieldVisibilityControl();
    system.assertequals(true,ext.DisplayShoreline );

    ext.getRepGroups();
		//PrdColors test input
    test.starttest();


    test.stoptest();        

	}	

	
}