class Position {
  final double lat;
  final double lan;

  Position({
  required  this.lat,
  required  this.lan,
  });
  factory Position.fromJson(json){
    return Position(lat: json['lat'], lan: json['lan']);
  }
}
