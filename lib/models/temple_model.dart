class TempleModel {
  TempleModel({
    required this.date,
    required this.temple,
    required this.address,
    required this.station,
    required this.memo,
    required this.gohonzon,
    required this.startPoint,
    required this.endPoint,
    required this.thumbnail,
    required this.lat,
    required this.lng,
    required this.photo,
  });

  factory TempleModel.fromJson(Map<String, dynamic> json) => TempleModel(
        date: DateTime.parse(json['date']),
        temple: json['temple'],
        address: json['address'],
        station: json['station'],
        memo: json['memo'],
        gohonzon: json['gohonzon'],
        startPoint: json['start_point'],
        endPoint: json['end_point'],
        thumbnail: json['thumbnail'],
        lat: json['lat'],
        lng: json['lng'],
        photo: List<String>.from(
            // ignore: avoid_dynamic_calls
            json['photo'].map((x) => x)),
      );
  DateTime date;
  String temple;
  String address;
  String station;
  String memo;
  String gohonzon;
  String startPoint;
  String endPoint;
  String thumbnail;
  String lat;
  String lng;
  List<String> photo;

  Map<String, dynamic> toJson() => {
        'date':
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        'temple': temple,
        'address': address,
        'station': station,
        'memo': memo,
        'gohonzon': gohonzon,
        'start_point': startPoint,
        'end_point': endPoint,
        'thumbnail': thumbnail,
        'lat': lat,
        'lng': lng,
        'photo': List<dynamic>.from(photo.map((x) => x)),
      };
}
