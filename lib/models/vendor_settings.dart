import 'package:suara/common/common.dart';

class VendorSettings{
  String uid;
  String businessName;
  String businessDesc;
  String fbURL;
  dynamic location;
  dynamic location2;
  String whatsappNo;
  String phoneNo;
  String category;
  bool isOnline;
  bool isLoc1Def;
  int credits;
  String salesContact;
  bool creditPolicy;
  DateTime lastOnline;

  toJson(){
    return{
      'uid':uid,
      'businessName':businessName,
      'businessDesc':businessDesc,
      'fbURL':fbURL,
      'location':{
        'latitude':location['latitude'],
        'longitude':location['longitude']
      },
      'location2':{
        'latitude':location2 == null ? 0.0 : location2['latitude'],
        'longitude':location2 == null ? 0.0 : location2['longitude']
      },
      'whatsappNo':whatsappNo,
      'phoneNo':phoneNo,
      'category':category,
      'isOnline':isOnline,
      'isLoc1Def':isLoc1Def,
      'credits':credits??initialCredit,
      'salesContact':salesContact,
      'creditPolicy':creditPolicy,
      'lastOnline':lastOnline
    };
  }
  VendorSettings(this.uid){
    isLoc1Def = true;
    isOnline = false;
    creditPolicy = false;
    lastOnline = DateTime.now();
  }

  VendorSettings.fromJson(dynamic f){
    uid = f['uid'];
    businessName = f['businessName'];
    businessDesc = f['businessDesc'];
    fbURL = f['fbURL'];
    location = f['location'];
    location2 = f['location2'];
    whatsappNo = f['whatsappNo'];
    phoneNo = f['phoneNo'];
    category = f['category'];
    isOnline = f['isOnline'] == null ? false : f['isOnline'];
    isLoc1Def = f['isLoc1Def'] == null ? true : f['isLoc1Def'];
    credits = f['credits'] ?? initialCredit;
    salesContact = f['salesContact'];
    creditPolicy = f['creditPolicy'];
    lastOnline = f['lastOnline'];
  }
}