class RemoteBlockMetadata {
  final String id;
  final double? latitude;
  final double? longitude;

  const RemoteBlockMetadata(
      {required this.id, required this.latitude, required this.longitude});

  factory RemoteBlockMetadata.fromJson(Map<String, dynamic> json) =>
      RemoteBlockMetadata(
          id: json['id'] as String,
          latitude: json['location']?['coordinates']?[1],
          longitude: json['location']?['coordinates']?[0]);
}
