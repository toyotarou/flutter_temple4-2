class LatLngTempleModel {
  LatLngTempleModel({
    required this.id,
    required this.city,
    required this.jinjachouId,
    required this.url,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.dist,
    required this.cnt,
  });

  factory LatLngTempleModel.fromJson(Map<String, dynamic> json) => LatLngTempleModel(
        id: json['id'],
        city: json['city'],
        jinjachouId: json['jinjachou_id'],
        url: json['url'],
        name: json['name'],
        address: json['address'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        dist: json['dist'],
        cnt: json['cnt'],
      );
  int id;
  String city;
  String jinjachouId;
  String url;
  String name;
  String address;
  String latitude;
  String longitude;
  String dist;
  int cnt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'jinjachou_id': jinjachouId,
        'url': url,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'dist': dist,
        'cnt': cnt,
      };
}
