class CareItemType {
  static const int item = 0;
  static const int mainMeal = 10; // breakfast, lunch, and dinner
  static const int subMeal = 11; // breakfast, lunch, and dinner
  static const int hydration = 12; // Water, coffee, tea, etc
  static const int movement = 13; // poop, pee, urine, feces
  static const int urine = 14;
  static const int feces = 15;
  static const int vital = 16; // Temperature, Pressure, Pulse
  static const int temperature = 17;
  static const int pressure = 18;
  static const int pulse = 19;
  static const int bathing = 20; // bath, shower
  static const int medication = 21;
  static const int snacks = 22; // food between meals
  static const int treatment = 23;
  static const int sleep = 24; // nap
  static const int teeth = 25; // brushing
  static const int housekeeping = 26;
  static const int messages = 27;
  static const int caregiver = 28;
  static const int note = 29;
}

class CareItem {
  int type;
  DateTime? startTime;
  DateTime? endTime;
  // optional note message
  String? note;
  // on a scale of one to five
  int? rate;
  CareItem({
    required this.type,
    this.startTime,
    this.endTime,
    this.note,
    this.rate,
  });
}

class MainMealCareItem extends CareItem {
  MainMealCareItem() : super(type: CareItemType.mainMeal);
}

class SubMealCareItem extends CareItem {
  SubMealCareItem() : super(type: CareItemType.subMeal);
}

class HydroCareItem extends CareItem {
  HydroCareItem() : super(type: CareItemType.hydration);
}

class UrineCareItem extends CareItem {
  UrineCareItem() : super(type: CareItemType.urine);
}

class FecesCareItem extends CareItem {
  FecesCareItem() : super(type: CareItemType.feces);
}

class TempCareItem extends CareItem {
  TempCareItem() : super(type: CareItemType.temperature);
}

class PressureCareItem extends CareItem {
  PressureCareItem() : super(type: CareItemType.pressure);
}

class PulseCareItem extends CareItem {
  PulseCareItem() : super(type: CareItemType.pulse);
}

class BathCareItem extends CareItem {
  BathCareItem() : super(type: CareItemType.bathing);
}

class MediCareItem extends CareItem {
  MediCareItem() : super(type: CareItemType.medication);
}

class SnackCareItem extends CareItem {
  SnackCareItem() : super(type: CareItemType.snacks);
}

class SleepCareItem extends CareItem {
  SleepCareItem() : super(type: CareItemType.sleep);
}

class TeethCareItem extends CareItem {
  TeethCareItem() : super(type: CareItemType.teeth);
}

class HouseKeepingCareItem extends CareItem {
  HouseKeepingCareItem() : super(type: CareItemType.housekeeping);
}

class MessageCareItem extends CareItem {
  MessageCareItem() : super(type: CareItemType.messages);
}

class CareGiverCareItem extends CareItem {
  CareGiverCareItem() : super(type: CareItemType.caregiver);
}

class NoteCareItem extends CareItem {
  NoteCareItem() : super(type: CareItemType.note);
}

/*
class CareItem extends CareItem {
  CareItem({CareItemType type}) : super(type: CareItemType.);
}
*/

class CareTimelineData {
  DateTime date;
  String recipient;
  List<CareItem>? careItems;

  CareTimelineData(
      {required this.date, required this.recipient, this.careItems});
}
