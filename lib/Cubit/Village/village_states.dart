import 'package:sa7el/Model/village_model.dart';

abstract class VillageStates {}

class VillaLoadingState extends VillageStates {}

class VillageSuccessState extends VillageStates {
  final List<Villages> villages;
  final List<Zones> zones;

  VillageSuccessState(this.villages, this.zones);
}

class VillageFilteredState extends VillageStates {
  final List<Villages> villages;
  final List<Zones> zones;

  VillageFilteredState(this.villages, this.zones);
}

class VillageSearchState extends VillageStates {
  final List<Villages> villages;
  final List<Zones> zones;

  VillageSearchState(this.villages, this.zones);
}

class VillageErrorState extends VillageStates {
  final String error;

  VillageErrorState(this.error);
}

class VillageEditLoadingState extends VillageStates {}

class VillageEditSuccessState extends VillageStates {}

class VillageEditErrorState extends VillageStates {
  final String error;
  VillageEditErrorState(this.error);
}

class VillageDeleteLoadingState extends VillageStates {}

class VillageDeleteSuccessState extends VillageStates {}

class VillageDeleteErrorState extends VillageStates {
  final String error;
  VillageDeleteErrorState(this.error);
}

class VillageAddLoadingState extends VillageStates {}

class VillageAddSuccessState extends VillageStates {}

class VillageAddErrorState extends VillageStates {
  final String error;
  VillageAddErrorState(this.error);
}