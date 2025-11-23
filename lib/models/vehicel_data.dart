class VehicleData {
  final double rpm;
  final double speed;
  final double engineTemp;
  final double intakeTemp;
  final double throttle;
  final double engineLoad;
  final double timingAdvance;

  final double maf;
  final double lambda;
  final double shortTermFuel;
  final double longTermFuel;

  final double boostPressure;
  final double baroPressure;
  final double preThrottlePressure;
  final double postThrottlePressure;
  final double absolutePressure;

  final double o2Sensor1;
  final double o2Sensor2;

  final bool dataValid;
  final DateTime lastUpdate;

  VehicleData({
    required this.rpm,
    required this.speed,
    required this.engineTemp,
    required this.intakeTemp,
    required this.throttle,
    required this.engineLoad,
    required this.timingAdvance,
    required this.maf,
    required this.lambda,
    required this.shortTermFuel,
    required this.longTermFuel,
    required this.boostPressure,
    required this.baroPressure,
    required this.preThrottlePressure,
    required this.postThrottlePressure,
    required this.absolutePressure,
    required this.o2Sensor1,
    required this.o2Sensor2,
    required this.dataValid,
    required this.lastUpdate,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      // Engine Data
        rpm: (json