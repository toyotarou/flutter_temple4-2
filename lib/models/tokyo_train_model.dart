import 'tokyo_station_model.dart';

class TokyoTrainModel {
  TokyoTrainModel({
    required this.trainNumber,
    required this.trainName,
    required this.station,
  });

  factory TokyoTrainModel.fromJson(Map<String, dynamic> json) =>
      TokyoTrainModel(
        trainNumber: json['train_number'],
        trainName: json['train_name'],
        station: List<TokyoStationModel>.from(

            // ignore: avoid_dynamic_calls
            json['station'].map((x) => TokyoStationModel.fromJson(x))),
      );
  int trainNumber;
  String trainName;
  List<TokyoStationModel> station;

  Map<String, dynamic> toJson() => {
        'train_number': trainNumber,
        'train_name': trainName,
        'station': List<dynamic>.from(station.map((x) => x.toJson())),
      };
}
