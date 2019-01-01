class VendorSettings{
  String uid;
  String businessName;
  String businessDesc;
  String fbURL;
  dynamic location;
  String ratings;

  toJson(){
    return{
      'uid':uid,
      'businessName':businessName,
      'businessDesc':businessDesc,
      'fbURL':fbURL,
      'location':{
        'latitude':location['latitude'],
        'longitude':location['longitude']
      }
    };
  }
  VendorSettings();

  VendorSettings.fromJson(dynamic f){
    uid = f['uid'];
    businessName = f['businessName'];
    businessDesc = f['businessDesc'];
    fbURL = f['fbURL'];
    location = f['location'];
  }
}