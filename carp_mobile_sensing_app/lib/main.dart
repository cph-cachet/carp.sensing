library mobile_sensing_app;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_realtime_chart/flutter_realtime_chart.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_audio_package/audio.dart';
import 'package:carp_backend/carp_backend.dart';
import 'dart:async';

part 'src/app.dart';
part 'src/sensing/sensing.dart';
part 'src/models/probe_models.dart';
part 'src/models/probe_description.dart';
part 'src/models/study_model.dart';
part 'src/models/data_models.dart';
part 'src/blocs/sensing_bloc.dart';
part 'src/ui/probe_list.dart';
part 'src/ui/data_viz.dart';
part 'src/ui/study_viz.dart';
part 'src/ui/cachet.dart';

void main() {
  runApp(App());
}
