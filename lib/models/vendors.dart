class Vendors{
  String uid;
  String businessName;
  String businessDesc;
  String distance;

  Vendors.fromJson(dynamic f){
    uid = f['uid'];
    businessDesc = f['businessDesc'];
    distance = f['distance'];
  }

  Vendors(this.uid,this.businessName,this.businessDesc,this.distance);

  toJson(){
    return{
      'uid':uid,
      'businessDesc':businessDesc,
      'distance':distance
    };
  }
}