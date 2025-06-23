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
