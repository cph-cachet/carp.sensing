/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of context;

/// Holds location information using the GPS format.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class LocationDatum extends CARPDatum {
  static const DataFormat CARP_DATA_FORMAT =
      DataFormat(NameSpace.CARP, ContextSamplingPackage.LOCATION);

  DataFormat get format => CARP_DATA_FORMAT;

  LocationDatum() : super();

  LocationDatum.fromLocationDto(LocationDto dto)
      : latitude = dto.latitude,
        longitude = dto.longitude,
        altitude = dto.altitude,
        accuracy = dto.accuracy,
        speed = dto.speed,
        speedAccuracy = dto.speedAccuracy,
        heading = dto.heading,
        time = DateTime.fromMillisecondsSinceEpoch(dto.time.toInt()),
        super();

  factory LocationDatum.fromJson(Map<String, dynamic> json) =>
      _$LocationDatumFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDatumToJson(this);

  /// The time when this location was collected.
  DateTime time;

  /// Latitude in GPS coordinates.
  double latitude;

  /// Longitude in GPS coordinates.
  double longitude;

  /// Altitude in GPS coordinates.
  double altitude;

  /// Accuracy in absolute measures.
  double accuracy;

  /// Estimated movement speed.
  double speed;

  /// Accuracy in speed estimation.
  ///
  /// Will always be 0 on iOS
  double speedAccuracy;

  /// Heading in degrees
  double heading;

  /// The 2D GPS coordinates [latitude, longitude].
  get gpsCoordinates => [latitude, longitude];

  String toString() =>
      super.toString() +
      'latitude: $latitude, '
          'longitude: $longitude, '
          'accuracy; $accuracy, '
          'altitude: $altitude, '
          'speed: $speed, '
          'speed_accuracy: $speedAccuracy, '
          'heading: $heading, '
          'time: $time';
}