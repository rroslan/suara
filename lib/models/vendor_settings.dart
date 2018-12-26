class VendorSettings{
  String uid;
  String businessName;
  String businessDesc;
  String fbURL;
  dynamic location;
  String ratings;

  toJson(){
    return{
      'businessName':businessName,
      'businessDesc':businessDesc,
      'fbURL':fbURL,
      'location':{
        'latitude':location['latitude'],
        'longitude':location['longitude']
      }
    };
  }
}