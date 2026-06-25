@IsTest
private class ScUserInfoControllerTest {
  @IsTest
  static void getUserDataSuccess() {
    Profile p = [
      SELECT Id
      FROM Profile
      WHERE UserType = 'PowerCustomerSuccess'
      LIMIT 1
    ];
    Account acc = new Account(Name = 'Test');
    insert acc;

    Contact con = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      AccountId = acc.Id,
      Email = 'test@gmail.com'
    );
    insert con;

    User communityUser = new User(
      Alias = 'test',
      Email = 'test@gmail.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Contact',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      ContactId = con.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'test@gmail.com'
    );
    insert communityUser;

    System.runAs(communityUser) {
      Test.startTest();
      Map<String, Object> result = ScUserInfoController.getUserData();
      Test.stopTest();

      System.Assert.areNotEqual(null, result);
    }

  }
}