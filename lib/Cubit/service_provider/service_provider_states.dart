class ServiceProviderStates {}

class ServiceProviderInitialState extends ServiceProviderStates {}

class ServiceProviderGetDataLoadingState extends ServiceProviderStates {}

class ServiceProviderGetDataSuccessState extends ServiceProviderStates {}

class ServiceProviderGetDataErrorState extends ServiceProviderStates {}

class ServiceProviderDeleteLoadingState extends ServiceProviderStates {}

class ServiceProviderDeleteSuccessState extends ServiceProviderStates {
  final String message;

  ServiceProviderDeleteSuccessState(this.message);
}

class ServiceProviderDeleteFailedState extends ServiceProviderStates {
  final String error;

  ServiceProviderDeleteFailedState(this.error);
}

class ServiceProviderEditSuccessState extends ServiceProviderStates {
  final String message;

  ServiceProviderEditSuccessState(this.message);
}

class ServiceProviderEditFailedState extends ServiceProviderStates {
  final String error;

  ServiceProviderEditFailedState(this.error);
}

class ServiceProviderAddLoadingState extends ServiceProviderStates {}

class ServiceProviderAddSuccessState extends ServiceProviderStates {
  final String message;
  ServiceProviderAddSuccessState(this.message);
}

class ServiceProviderAddFailedState extends ServiceProviderStates {
  final String error;
  ServiceProviderAddFailedState(this.error);
}
