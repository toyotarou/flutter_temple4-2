class TempleLatLngModel {

  TempleLatLngModel({
    required this.temple,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory TempleLatLngModel.fromJson(Map<String, dynamic> json) => TempleLatLngModel(
        temple: json['temple'],
        address: json['address'],
        lat: json['lat'],
        lng: json['lng'],
      );
  String temple;
  String address;
  String lat;
  String lng;

  Map<String, dynamic> toJson() => {
        'temple': temple,
        'address': address,
        'lat': lat,
        'lng': lng,
      };
}
