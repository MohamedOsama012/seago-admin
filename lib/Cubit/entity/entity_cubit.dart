import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EntityCubit<T, S> extends Cubit<S> {
  EntityCubit(super.initialState);

  Future<void> getData();
  Future<void> deleteData(int id);
  Future<void> addData(T item);
  Future<void> editData(T item);
  abstract List<T> items;
}
