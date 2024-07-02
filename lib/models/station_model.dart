class StationModel {
  StationModel({
    required this.id,
    required this.stationName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.lineNumber,
    required this.lineName,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) => StationModel(
        id: json['id'],
        stationName: json['station_name'],
        address: json['address'],
        lat: json['lat'],
        lng: json['lng'],
        lineNumber: json['line_number'],
        lineName: json['line_name'],
      );
  int id;
  String stationName;
  String address;
  String lat;
  String lng;
  String lineNumber;
  String lineName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'station_name': stationName,
        'address': address,
        'lat': lat,
        'lng': lng,
        'line_number': lineNumber,
        'line_name': lineName,
      };
}
