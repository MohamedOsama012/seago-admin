import 'package:sa7el/Model/maintenance_model.dart';

abstract class MaintenanceStates {}

class MaintenanceLoadingState extends MaintenanceStates {}

class MaintenanceSuccessState extends MaintenanceStates {
  final List<Providers> providers;
  final List<MaintenanceTypes> maintenanceTypes;
  final List<Villages> villages;

  MaintenanceSuccessState(this.providers, this.maintenanceTypes, this.villages);
}

class MaintenanceFilteredState extends MaintenanceStates {
  final List<Providers> providers;
  final List<MaintenanceTypes> maintenanceTypes;
  final List<Villages> villages;

  MaintenanceFilteredState(this.providers, this.maintenanceTypes, this.villages);
}

class MaintenanceSearchState extends MaintenanceStates {
  final List<Providers> providers;
  final List<MaintenanceTypes> maintenanceTypes;
  final List<Villages> villages;

  MaintenanceSearchState(this.providers, this.maintenanceTypes, this.villages);
}

class MaintenanceErrorState extends MaintenanceStates {
  final String error;

  MaintenanceErrorState(this.error);
}

class MaintenanceEditLoadingState extends MaintenanceStates {}

class MaintenanceEditSuccessState extends MaintenanceStates {}

class MaintenanceEditErrorState extends MaintenanceStates {
  final String error;
  MaintenanceEditErrorState(this.error);
}

class MaintenanceDeleteLoadingState extends MaintenanceStates {}

class MaintenanceDeleteSuccessState extends MaintenanceStates {}

class MaintenanceDeleteErrorState extends MaintenanceStates {
  final String error;
  MaintenanceDeleteErrorState(this.error);
}

class MaintenanceAddLoadingState extends MaintenanceStates {}

class MaintenanceAddSuccessState extends MaintenanceStates {}

class MaintenanceAddErrorState extends MaintenanceStates {
  final String error;
  MaintenanceAddErrorState(this.error);
}