enum APIPath {
  getAllTemple,
  getTempleLatLng,
  getAllStation,
  templeNotReached,
  getTempleListTemple,
  getTokyoTrainStation,
  getLatLngTemple,
  insertTempleRoute,
}

extension APIPathExtension on APIPath {
  String? get value {
    switch (this) {
      case APIPath.getAllTemple:
        return 'getAllTemple';
      case APIPath.getTempleLatLng:
        return 'getTempleLatLng';
      case APIPath.getAllStation:
        return 'getAllStation';
      case APIPath.templeNotReached:
        return 'templeNotReached';
      case APIPath.getTempleListTemple:
        return 'getTempleListTemple';
      case APIPath.getTokyoTrainStation:
        return 'getTokyoTrainStation';
      case APIPath.getLatLngTemple:
        return 'getLatLngTemple';
      case APIPath.insertTempleRoute:
        return 'insertTempleRoute';
    }
  }
}
