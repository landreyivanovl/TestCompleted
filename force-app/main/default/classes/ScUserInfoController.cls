public class ScUserInfoController {
  public class UserIsNotFoundException extends Exception {
  }

  @AuraEnabled
  public static Map<String, Object> getUserData() {
    Map<String, Object> userDataResult = new Map<String, Object>();

    try {
      User currentUser = [
        SELECT
          FullPhotoUrl,
          FirstName,
          LastName,
          MobilePhone,
          Phone,
          Email,
          Street,
          City,
          State,
          PostalCode,
          Country
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];

      UserData userData = new UserData();
      userData.imageUrl = currentUser.FullPhotoUrl;
      userData.firstName = currentUser.FirstName;
      userData.lastName = currentUser.LastName;
      userData.mobileNumber = currentUser.MobilePhone;
      userData.phoneNumber = currentUser.Phone;
      userData.email = currentUser.Email;
      userData.address = new AddressData();

      userData.address.street = currentUser.Street;
      userData.address.city = currentUser.City;
      userData.address.state = currentUser.State;
      userData.address.postalCode = currentUser.PostalCode;
      userData.address.country = currentUser.Country;

      userDataResult.put('status', 'success');
      userDataResult.put('userData', userData);
    } catch (Exception userNotFoundEx) {
      if (userNotFoundEx instanceof QueryException) {
        userDataResult.put('status', 'error');
        userDataResult.put('errorMessage', 'user is not found');
      }
    }

    return userDataResult;
  }

  public class UserData {
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String lastName;
    @AuraEnabled
    public String mobileNumber;
    @AuraEnabled
    public String phoneNumber;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public AddressData address;
  }

  public class AddressData {
    @AuraEnabled
    public String street;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String postalCode;
    @AuraEnabled
    public String country;
  }
}