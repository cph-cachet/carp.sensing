part of mobile_sensing_app;

class DataVisualization extends StatefulWidget {
  DataVisualization({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataVisualizationState();
}

typedef ValueToDoubleConverter<T extends Datum> = double Function(T v);

typedef DatumPredicate = bool Function(CARPDatum m);

class DatumType<T extends CARPDatum> {
  final String name;
  final DatumPredicate predicate;
  final Map<String, double Function(T)> extractors;
  static DatumPredicate predicateFromName(String name) =>
      (d) => d.format.name == name;
  DatumType({this.name, predicate, this.extractors})
      : this.predicate = predicate ?? predicateFromName(name);

  List<String> get fieldNames => extractors.keys.toList();

  List<List<DataPoint>> extractFrom(CARPDatum d, DateTime startTime) {
    if (!predicate(d)) {
      return List.filled(extractors.length, List<DataPoint>());
    } else {
      return extractors.values
          .map((e) => applyExtractor(
              e, d, (d) => d.difference(startTime).inSeconds.toDouble()))
          .toList();
    }
  }

  List<DataPoint> applyExtractor(double Function(T) extractor, CARPDatum d,
          double Function(DateTime) timeSince) =>
      [DataPoint(time: timeSince(d.timestamp), value: extractor(d as T))];
}

class MultiDatumType<T extends CARPDatum> extends DatumType<T> {
  MultiDatumType({name, predicate, extractors})
      : super(name: name, predicate: predicate, extractors: extractors);
  List<DataPoint> applyExtractor(double Function(T) extractor, CARPDatum d,
          double Function(DateTime) timeSince) =>
      (d as MultiDatum).data.cast<T>().map(
          (v) => DataPoint(time: timeSince(v.timestamp), value: extractor(v)));
}

class _DataVisualizationState extends State<DataVisualization> {
  @override
  Widget build(BuildContext context) {
    final DateTime startTime = DateTime.now();
    final List<DatumType> measureExtractors = [
      DatumType<FreeMemoryDatum>(name: "memory", extractors: {
        "free_physical_memory": (v) =>
            v.freePhysicalMemory.toDouble() / 1024 / 1024 / 100,
        "free_virtual_memory": (v) =>
            v.freeVirtualMemory.toDouble() / 1024 / 1024 / 100,
      }),
      /*DatumType<LocationDa(name: "location", extractors: {
        "latitude": (v) => v.latitude / 100.0,
        "longitude": extractNonNull("longitude", (v) => (v as double) / 100.0),
        "altitude": extractNonNull("altitude", (v) => (v as double) / 5000.0),
        "accuracy": extractNonNull("accuracy", (v) => (v as double) / 10),
        "speed": extractNonNull("speed", (v) => (v as double) / 100)
      }),*/
      DatumType<PedometerDatum>(name: "pedometer", extractors: {
        "step_count": (v) => v.stepCount.toDouble() / 30000
      }),
      DatumType<BatteryDatum>(name: "battery", extractors: {
        "battery_level": (v) => v.batteryLevel.toDouble() / 100.0
      }),
      MultiDatumType<AccelerometerDatum>(name: "accelerometer", extractors: {
        "accel_x": (AccelerometerDatum v) => v.x,
        "accel_y": (AccelerometerDatum v) => v.y,
        "accel_z": (AccelerometerDatum v) => v.z
      }),
      DatumType<LightDatum>(name: "light", extractors: {
        "mean_lux": (v) => v.meanLux / 1000,
        "std_lux": (v) => v.stdLux / 1000,
        "min_lux": (v) => v.minLux / 1000,
        "max_lux": (v) => v.maxLux / 1000
      }),
      DatumType<ScreenDatum>(name: "screen", extractors: {
        "screen_event":
            (v) => v.screenEvent == "SCREEN_OFF" ? 0.0 : 1.0
      }),
      /*DatumType<Noise(name: "noise", extractors: {
        "mean_decibel": extractNonNull("mean_decibel", (v) => v as double),
        "std_decibel": extractNonNull("std_decibel", (v) => v as double),
        "min_decibel": extractNonNull("min_decibel", (v) => v as double),
        "max_decibel": extractNonNull("max_decibel", (v) => v as double)
      }),*/
    MultiDatumType<GyroscopeDatum>(name: "gyroscope", extractors: {
        "gyro_x": (GyroscopeDatum v) => v.x,
        "gyro_y": (GyroscopeDatum v) => v.y,
        "gyro_z": (GyroscopeDatum v) => v.z
      }),
    ];
    final Stream<Datum> dataStream = bloc.sensing.controller.events;
    final extractors = bloc.runningProbes.fold(<DatumType>[], (m, p) {
      m.addAll(measureExtractors.where((e) => e.name == p.measure.type.name));
      return m;
    }) as List<DatumType>;
    Stream<ChartData> cds = dataStream.map((m) {
      final ts = (m as CARPDatum).timestamp;
      final double time = ts.difference(startTime).inSeconds.toDouble();
      final points =
          extractors.expand((e) => e.extractFrom(m, startTime)).toList();
      return ChartData(currentTime: time, points: points);
    });
    final realtimeChart = RealtimeChart(
      chartInfo: ChartInfo(
          minY: 0.0,
          maxY: 1.0,
          seriesInfos: extractors
              .expand((e) => e.fieldNames)
              .map<SeriesInfo>((k) => SeriesInfo(
                  color: Color(k.hashCode << 0).withOpacity(1.0), name: k))
              .toList(),
          timeAxisRange: 30),
      chartDataStream: cds,
      chartArarHeight: 400,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Data Visualization'),
        ),
        body: realtimeChart);
  }
}
