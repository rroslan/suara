class AnonymouseUser{
  String id;
  double latitude;
  double longitude;

  toJson(String id, double lat, double long){
    return {
      'id':id,
      'lat':lat.toString(),
      'long': long.toString()
    };
  }
}