abstract class MallsStates {}

class MallsInitialState extends MallsStates {}

class MallsGetDataLoadingState extends MallsStates {}

class MallsGetDataSuccessState extends MallsStates {}

class MallsGetDataErrorState extends MallsStates {
  final String error;

  MallsGetDataErrorState(this.error);
}

class MallsAddInitialState extends MallsStates {}

class MallsAddLoadingState extends MallsStates {}

class MallsAddSuccessState extends MallsStates {
  final String successMessage;

  MallsAddSuccessState(this.successMessage);
}

class MallsAddFailedState extends MallsStates {
  final String errMessage;

  MallsAddFailedState(this.errMessage);
}

class MallsEditInitialState extends MallsStates {}

class MallsEditLoadingState extends MallsStates {}

class MallsEditSuccessState extends MallsStates {
  final String successMessage;

  MallsEditSuccessState(this.successMessage);
}

class MallsEditFailedState extends MallsStates {
  final String errMessage;

  MallsEditFailedState(this.errMessage);
}

class MallsDeleteInitialState extends MallsStates {}

class MallsDeleteLoadingState extends MallsStates {}

class MallsDeleteSuccessState extends MallsStates {
  final String successMessage;

  MallsDeleteSuccessState(this.successMessage);
}

class MallsDeleteFailedState extends MallsStates {
  final String errMessage;

  MallsDeleteFailedState(this.errMessage);
}
