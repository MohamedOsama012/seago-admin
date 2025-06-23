abstract class EntityState {}

class EntityInitial extends EntityState {}

class EntityLoading extends EntityState {}

class EntityLoaded<T> extends EntityState {
  final List<T> items;
  EntityLoaded(this.items);
}

class EntityError extends EntityState {
  final String message;
  EntityError(this.message);
}
