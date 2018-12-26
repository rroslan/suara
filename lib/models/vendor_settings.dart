class VendorSettings{
  String uid;
  String businessName;
  String businessDesc;
  String fbURL;
  dynamic location;
  String ratings;

  toJson(String businessName, String businessDesc, String fbURL,String latitude, String longitude){
    return{
      'businessName':businessName,
      'businessDesc':businessDesc,
      'fbURL':fbURL,
      'location':{
        'latitude':latitude,
        'longitude':longitude
      }
    };
  }
}