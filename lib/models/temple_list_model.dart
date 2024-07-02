class TempleListModel {
  TempleListModel({
    required this.id,
    required this.city,
    required this.jinjachouId,
    required this.url,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.nearStation,
  });

  factory TempleListModel.fromJson(Map<String, dynamic> json) =>
      TempleListModel(
        id: json['id'],
        city: json['city'],
        jinjachouId: json['jinjachou_id'],
        url: json['url'],
        name: json['name'],
        address: json['address'],
        lat: json['lat'],
        lng: json['lng'],
        nearStation: json['near_station'],
      );
  int id;
  String city;
  String jinjachouId;
  String url;
  String name;
  String address;
  String lat;
  String lng;
  String nearStation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'jinjachou_id': jinjachouId,
        'url': url,
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'near_station': nearStation,
      };
}
