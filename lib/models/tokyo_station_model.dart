class TokyoStationModel {

  TokyoStationModel({
    required this.id,
    required this.stationName,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory TokyoStationModel.fromJson(Map<String, dynamic> json) => TokyoStationModel(
        id: json['id'],
        stationName: json['station_name'],
        address: json['address'],
        lat: json['lat'],
        lng: json['lng'],
      );
  String id;
  String stationName;
  String address;
  String lat;
  String lng;

  Map<String, dynamic> toJson() => {
        'id': id,
        'station_name': stationName,
        'address': address,
        'lat': lat,
        'lng': lng,
      };
}
