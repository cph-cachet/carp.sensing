/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_core_domain;

/// Any condition on a device ([DeviceDescriptor]) which starts or stops [TaskDescriptor]s
/// at certain points in time when the condition applies.
/// The condition can either be time-bound, based on data streams,
/// initiated by a user of the platform, or a combination of these.
///
/// The [Trigger] class is abstract. Use sub-classes of [CAMSTrigger] implements
/// the specific behavior / timing of a trigger.
class Trigger {
  /// The device role name from which the trigger originates.
  String sourceDeviceRoleName;

  /// Determines whether the trigger needs to be evaluated on a master
  /// device ([MasterDeviceDescriptor]).
  /// For example, this is the case when the trigger is time bound and needs
  /// to be evaluated by a task scheduler running on a master device.
  bool requiresMasterDevice;

  Trigger() : super();
}