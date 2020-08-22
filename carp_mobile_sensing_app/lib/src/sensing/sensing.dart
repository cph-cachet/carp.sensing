part of mobile_sensing_app;

/// This class implements the sensing layer incl. setting up a [Study] with [Task]s and [Measure]s.
class Sensing {
  StudyController controller;

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (controller != null) ? controller.executor.probes : List();

  Sensing() : super() {
    // create and register external sampling packages
    //SamplingPackageRegistry.register(ConnectivitySamplingPackage());
    SamplingPackageRegistry.register(ContextSamplingPackage());
    SamplingPackageRegistry.register(CommunicationSamplingPackage());
    SamplingPackageRegistry.register(AudioSamplingPackage());
    SamplingPackageRegistry.register(AppsSamplingPackage());
  }

  /// Initialize and setup sensing.
  Future<void> init() async {
    // Create a Study Controller that can manage this study, initialize it, and start it.
    controller = StudyController(bloc.study);

    // The following study controller will use the default privacy schema, if used instead.
    //controller = StudyController(study, privacySchemaName: PrivacySchema.DEFAULT); // a controller w. privacy

    // Initialize the controller -- remember to await initialization before starting
    await controller.initialize();

    // Listening on all data events from the study and print it (for debugging purpose).
    controller.events.forEach(print);

    // Listening on a specific probe
    //ProbeRegistry.probes[DataType.LOCATION].events.forEach(print);

    // Listening on data manager events
    // controller.dataManager.events.forEach(print);
  }

  /// Stop sensing.
  void stop() async {
    controller.stop();
  }
}

/// A [StudyManager] that can create [Study] locally on this phone.
class LocalStudyManager implements StudyManager {
  Future<void> initialize() {}

  Study _study;

  /// Return a [Study] based on the [studyId].
  ///
  /// This method will return a study with all the available [Measure]s enabled,
  /// i.e. at study with as many sensors enabled as possible.
  /// Note that there are two ways to set up the study:
  ///
  ///  * using the [SamplingSchema] approach
  ///  * creating the study by specifying [Trigger]s, [Task]s, and [Measure]s by hand
  ///
  Future<Study> getStudy(String studyId) async {
    return _getStudyWithSelectedMeasuresFromCommonSamplingSchema(studyId);
    //return _getConditionalSamplingStudy('#1');
  }

  Future<Study> _getStudyWithAllMeasuresFromCommonSamplingSchema(
      String studyId) async {
    if (_study == null) {
      _study = Study(studyId, bloc.username)
        ..name = 'CAMS Demo Study #1'
        ..description =
            'This study is generated by using the common Sampling Schema from all Sampling Packages. '
                'It takes all available measures with their default / commonn settings'
        ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
        ..addTriggerTask(
            ImmediateTrigger(),
            Task()
              ..measures = SamplingSchema.common(namespace: NameSpace.CARP)
                  .measures
                  .values
                  .toList());
    }
    return _study;
  }

  Future<Study> _getStudyWithMostMeasuresFromDebugSamplingSchema(
      String studyId) async {
    if (_study == null) {
      _study = Study(studyId, bloc.username)
        ..name = 'CAMS Demo Study #2'
        ..description =
            'This study is generated by using the common Sampling Schema all Sampling Packages. '
                'It defines most measures with their default / commonn settings'
        ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
        ..addTriggerTask(
            ImmediateTrigger(),
            Task()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  // we are not sampling accelerometer & gyroscope since they generate a LOT of data...
                  //SensorSamplingPackage.ACCELEROMETER,
                  //SensorSamplingPackage.GYROSCOPE,
                  SensorSamplingPackage.LIGHT,
                  SensorSamplingPackage.PEDOMETER,
                ],
              ))
//        ..addTriggerTask(
//            DelayedTrigger(delay: 10 * 1000),
//            Task()
//              ..measures = SamplingSchema.debug().getMeasureList(
//                namespace: NameSpace.CARP,
//                types: [
//                  ConnectivitySamplingPackage.BLUETOOTH,
//                  ConnectivitySamplingPackage.WIFI,
//                  ConnectivitySamplingPackage.CONNECTIVITY,
//                ],
//              ))
        ..addTriggerTask(
            ImmediateTrigger(),
            Task()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  AppsSamplingPackage.APP_USAGE,
                  AppsSamplingPackage.APPS,
                ],
              ))
        ..addTriggerTask(
            ImmediateTrigger(),
            Task()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  DeviceSamplingPackage.MEMORY,
                  DeviceSamplingPackage.DEVICE,
                  DeviceSamplingPackage.BATTERY,
                  DeviceSamplingPackage.SCREEN,
                ],
              ))
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(seconds: 20)),
            Task()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.WEATHER,
                  ContextSamplingPackage.AIR_QUALITY,
                ],
              ))
        ..addTriggerTask(
            ImmediateTrigger(),
            Task()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.LOCATION,
                  ContextSamplingPackage.GEOLOCATION,
                  ContextSamplingPackage.ACTIVITY,
                  ContextSamplingPackage.GEOFENCE,
                ],
              ))
        // AUDIO and NOISE cannot be used in the same study since they conflict in using the microphone...
//        ..addTriggerTask(
//            PeriodicTrigger(period: 1 * 60 * 1000, duration: 5 * 1000),
//            Task('Audio')
//              ..measures.add(AudioMeasure(
//                MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
//                name: "Audio Recording",
//                studyId: studyId,
//              )))
        ..addTriggerTask(
            ImmediateTrigger(),
            AutomaticTask()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  // Note that if the eSense devices are used (see below),
                  // noise will be collected from them, i.e. around the user's head.
                  AudioSamplingPackage.NOISE,
                ],
              ))
        ..addTriggerTask(
            ImmediateTrigger(),
            AutomaticTask()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  CommunicationSamplingPackage.CALENDAR,
                  CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
                  CommunicationSamplingPackage.TEXT_MESSAGE,
                  CommunicationSamplingPackage.PHONE_LOG,
                  CommunicationSamplingPackage.TELEPHONY,
                ],
              ));
    }
    return _study;
  }

  Future<Study> _getStudyWithSelectedMeasuresFromCommonSamplingSchema(
      String studyId) async {
    if (_study == null) {
      _study = Study(studyId, bloc.username)
        ..name = 'CAMS Demo Study #3'
        ..description =
            'This study is generated by using the common Sampling Schema from selected Sampling Packages. '
                'It defines specific measures with their default / commonn settings.'
                'It specify a simple context sampling of things like location, activity, etc.'
        ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(seconds: 20)),
            AutomaticTask()
              ..measures = SamplingSchema.common().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.WEATHER,
                  //ContextSamplingPackage.AIR_QUALITY,
                  ContextSamplingPackage.LOCATION,
                  ContextSamplingPackage.MOBILITY,
                ],
              ))
        ..addTriggerTask(
            ImmediateTrigger(),
            AutomaticTask()
              ..measures = custom.getMeasureList(
                types: [
                  AppsSamplingPackage.APPS,
                  AppsSamplingPackage.APP_USAGE,
                ],
              ))
        ..addTriggerTask(
            ImmediateTrigger(),
            AutomaticTask()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  SensorSamplingPackage.LIGHT,
                  SensorSamplingPackage.PEDOMETER,
                  ContextSamplingPackage.GEOLOCATION,
                  ContextSamplingPackage.ACTIVITY,
                  ContextSamplingPackage.GEOFENCE,
                  AudioSamplingPackage.NOISE,
                  ContextSamplingPackage.MOBILITY,
                ],
              ));
    }
    return _study;
  }

  Future<Study> _getStudyWithSelectedMeasuresFromCustomSamplingSchema(
      String studyId) async {
    if (_study == null) {
      _study = Study(studyId, bloc.username)
            ..name = 'CAMS Demo Study #4'
            ..description = custom.description
            ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
            ..addTriggerTask(
                ImmediateTrigger(),
                AutomaticTask()
                  ..measures = custom.getMeasureList(
                    types: [
                      SensorSamplingPackage.LIGHT,
                      AppsSamplingPackage.APPS,
                      DeviceSamplingPackage.BATTERY,
                      DeviceSamplingPackage.SCREEN,
                      CommunicationSamplingPackage.PHONE_LOG,
                      CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
                      ContextSamplingPackage.LOCATION,
                      ContextSamplingPackage.ACTIVITY,
                    ],
                  ))
//            ..addTriggerTask(
//                DelayedTrigger(delay: 10 * 1000),
//                AutomaticTask()
//                  ..measures = custom.getMeasureList(
//                    namespace: NameSpace.CARP,
//                    types: [
//                      ConnectivitySamplingPackage.BLUETOOTH,
//                      ConnectivitySamplingPackage.WIFI,
//                    ],
//                  ))
            ..addTriggerTask(
                PeriodicTrigger(period: Duration(minutes: 20)),
                AutomaticTask()
                  ..measures = custom.getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      AppsSamplingPackage.APP_USAGE,
                    ],
                  ))
            ..addTriggerTask(
                PeriodicTrigger(period: Duration(minutes: 30)),
                AutomaticTask()
                  ..measures = custom.getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.WEATHER,
                    ],
                  ))
          //
          ;
    }
    return _study;
  }

  Future<Study> _getStudyWithAudioMeasures(String studyId) async {
    if (_study == null) {
      _study = Study(studyId, bloc.username)
            ..name = 'CAMS Demo Study #5'
            ..description = "Sampling mostly audio"
            ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
            ..addTriggerTask(
                ImmediateTrigger(),
                Task()
                  ..measures = SamplingSchema.common().getMeasureList(
                    types: [
                      SensorSamplingPackage.LIGHT,
                      DeviceSamplingPackage.BATTERY,
                      DeviceSamplingPackage.SCREEN,
                      ContextSamplingPackage.LOCATION,
                      ContextSamplingPackage.ACTIVITY,
                    ],
                  ))
            // AUDIO and NOISE cannot be used in the same study since they conflict in using the microphone...
            ..addTriggerTask(
                PeriodicTrigger(
                    period: Duration(minutes: 1),
                    duration: Duration(seconds: 5)),
                AutomaticTask(name: 'Audio')
                  ..measures.add(AudioMeasure(
                    MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
                    name: "Audio Recording",
                    studyId: studyId,
                  )))
          //
          ;
    }
    return _study;
  }

  Future<Study> _getConditionalSamplingStudy(String studyId) async {
    if (_study == null) {
      _study = Study(studyId, bloc.username)
            ..name = 'Conditional Sampling Study'
            ..description =
                'This is a study for testing and debugging Conditional Sampling'
            ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
            ..addTriggerTask(
                ConditionalSamplingEventTrigger(
                    measureType: MeasureType(
                        NameSpace.CARP, ContextSamplingPackage.LOCATION),
                    resumeCondition: (datum) {
                      return true;
                    },
                    pauseCondition: (datum) {
                      return true;
                    }),
                AutomaticTask()
                  ..measures = SamplingSchema.debug().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.WEATHER,
                      //ContextSamplingPackage.AIR_QUALITY,
                    ],
                  ))
            ..addTriggerTask(
                PeriodicTrigger(
                    period: Duration(seconds: 20),
                    duration: Duration(seconds: 2)),
                //ImmediateTrigger(),
                AutomaticTask()
                  ..measures = SamplingSchema.debug().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.LOCATION,
                      //ContextSamplingPackage.GEOLOCATION,
                    ],
                  ))
            ..addTriggerTask(
                ImmediateTrigger(),
                AutomaticTask()
                  ..measures = custom.getMeasureList(
                    types: [
                      SensorSamplingPackage.LIGHT,
                      AppsSamplingPackage.APPS,
                      DeviceSamplingPackage.BATTERY,
                      DeviceSamplingPackage.SCREEN,
                      CommunicationSamplingPackage.PHONE_LOG,
                      CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
                      ContextSamplingPackage.LOCATION,
                      ContextSamplingPackage.ACTIVITY,
                    ],
                  ))
          //
          ;
    }
    return _study;
  }

  /// Return a [DataEndPoint] of the specified type.
  DataEndPoint getDataEndpoint(String type) {
    assert(type != null);
    switch (type) {
      case DataEndPointTypes.PRINT:
        return new DataEndPoint(DataEndPointTypes.PRINT);
      case DataEndPointTypes.FILE:
        return FileDataEndPoint(
            bufferSize: 50 * 1000, zip: true, encrypt: false);
      default:
        return new DataEndPoint(DataEndPointTypes.PRINT);
    }
  }
}

/// A custom, study-specific sampling schema.
SamplingSchema get custom => SamplingSchema()
  ..type = SamplingSchemaType.NORMAL
  ..name = 'AWARE equivalent sampling schema'
  ..description =
      'This Study is a technical evaluation of the CARP Mobile Sensing framework. It simulates the AWARE configuration in order to compare data sampling and battery drain.'
  ..powerAware = false
  ..measures.addEntries([
    MapEntry(
        SensorSamplingPackage.LIGHT,
        PeriodicMeasure(
            MeasureType(NameSpace.CARP, SensorSamplingPackage.LIGHT),
            name: "Ambient Light",
            frequency: Duration(seconds: 60),
            // How often to start a measure
            duration: Duration(seconds: 1) // Window size
            )),
    MapEntry(
        AppsSamplingPackage.APPS,
        Measure(
          MeasureType(NameSpace.CARP, AppsSamplingPackage.APPS),
          name: 'Installed Apps',
        )),
    MapEntry(
        AppsSamplingPackage.APP_USAGE,
        MarkedMeasure(
            MeasureType(NameSpace.CARP, AppsSamplingPackage.APP_USAGE),
            name: 'Apps Usage',
            history: Duration(days: 1))),
    MapEntry(
        DeviceSamplingPackage.BATTERY,
        Measure(MeasureType(NameSpace.CARP, DeviceSamplingPackage.BATTERY),
            name: 'Battery')),
    MapEntry(
        DeviceSamplingPackage.SCREEN,
        Measure(MeasureType(NameSpace.CARP, DeviceSamplingPackage.SCREEN),
            name: 'Screen Activity (lock/on/off)')),
//    MapEntry(
//        ConnectivitySamplingPackage.BLUETOOTH,
//        PeriodicMeasure(MeasureType(NameSpace.CARP, ConnectivitySamplingPackage.BLUETOOTH),
//            name: 'Nearby Devices (Bluetooth Scan)', frequency: 60 * 1000, duration: 3 * 1000)),
//    MapEntry(
//        ConnectivitySamplingPackage.WIFI,
//        PeriodicMeasure(MeasureType(NameSpace.CARP, ConnectivitySamplingPackage.WIFI),
//            name: 'Wifi network names (SSID / BSSID)', frequency: 60 * 1000, duration: 5 * 1000)),
    MapEntry(
        CommunicationSamplingPackage.PHONE_LOG,
        MarkedMeasure(
            MeasureType(NameSpace.CARP, CommunicationSamplingPackage.PHONE_LOG),
            name: 'Phone Log',
            history: Duration(days: 1))),
    MapEntry(
        CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
        Measure(
            MeasureType(
                NameSpace.CARP, CommunicationSamplingPackage.TEXT_MESSAGE_LOG),
            name: 'Text Message (SMS) Log')),
    MapEntry(
        CommunicationSamplingPackage.TEXT_MESSAGE,
        Measure(
            MeasureType(
                NameSpace.CARP, CommunicationSamplingPackage.TEXT_MESSAGE),
            name: 'Text Message (SMS)')),
    MapEntry(
        ContextSamplingPackage.LOCATION,
        LocationMeasure(
            MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
            name: 'Location',
            enabled: true)),
    MapEntry(
        ContextSamplingPackage.ACTIVITY,
        Measure(MeasureType(NameSpace.CARP, ContextSamplingPackage.ACTIVITY),
            name: 'Activity Recognition')),
    MapEntry(
        ContextSamplingPackage.WEATHER,
        WeatherMeasure(
            MeasureType(NameSpace.CARP, ContextSamplingPackage.WEATHER),
            name: 'Local Weather',
            apiKey: '12b6e28582eb9298577c734a31ba9f4f')),
  ]);
