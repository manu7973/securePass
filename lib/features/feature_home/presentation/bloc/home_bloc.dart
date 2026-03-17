import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/AddPasswordUseCase.dart';
import '../../domain/DeletePasswordUseCase.dart';
import '../../domain/FilterPasswords.dart';
import '../../domain/GetPasswordsUseCase.dart';
import '../../domain/PasswordEntity.dart';
import '../../domain/UpdatePasswordUseCase.dart';
import 'home_event.dart';
import 'home_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final GetPasswordsUseCase getPasswords;
  final AddPasswordUseCase addPassword;
  final DeletePasswordUseCase deletePassword;
  final UpdatePasswordUseCase updatePassword;

  List<PasswordEntity> _allPasswords = [];
  bool _showFavoritesOnly = false; // runtime only

  bool get isFavoritesOnly => _showFavoritesOnly;

  PasswordBloc({
    required this.getPasswords,
    required this.addPassword,
    required this.deletePassword,
    required this.updatePassword,
  }) : super(PasswordInitial()) {
    on<LoadPasswords>(_onLoad);
    on<AddPassword>(_onAdd);
    on<DeletePassword>(_onDelete);
    on<UpdatePassword>(_onUpdate);
    on<SearchPasswords>(_onSearch);
    on<ToggleFavoritePassword>(_onToggleFavorite);
    on<FilterPasswords>(_onFilter);
  }

  Future<void> _onLoad(
      LoadPasswords event,
      Emitter<PasswordState> emit,
      ) async {
    emit(PasswordLoading());
    _allPasswords = await getPasswords();
    _emitFiltered(emit);
  }

  Future<void> _onAdd(AddPassword event, Emitter<PasswordState> emit) async {
    await addPassword(event.entity);
    add(LoadPasswords());
  }

  Future<void> _onDelete(
      DeletePassword event,
      Emitter<PasswordState> emit,
      ) async {
    await deletePassword(event.id);
    add(LoadPasswords());
  }

  Future<void> _onUpdate(
      UpdatePassword event,
      Emitter<PasswordState> emit,
      ) async {
    await updatePassword(event.entity);
    add(LoadPasswords());
  }

  void _onSearch(
      SearchPasswords event,
      Emitter<PasswordState> emit,
      ) {
    final query = event.query.trim().toLowerCase();

    final baseList = _showFavoritesOnly
        ? _allPasswords.where((p) => p.isfav).toList()
        : _allPasswords;

    final filtered = query.isEmpty
        ? baseList
        : baseList
        .where((p) => p.site.toLowerCase().contains(query))
        .toList();

    // emit(filtered.isEmpty ? PasswordEmpty() : PasswordLoaded(filtered));
    emit(
      filtered.isEmpty
          ? PasswordEmpty(isFiltered: _showFavoritesOnly)
          : PasswordLoaded(filtered),
    );
  }

  Future<void> _onToggleFavorite(
      ToggleFavoritePassword event,
      Emitter<PasswordState> emit,
      ) async {
    final updatedEntity = PasswordEntity(
      id: event.entity.id,
      site: event.entity.site,
      username: event.entity.username,
      password: event.entity.password,
      category: event.entity.category,
      isfav: !event.entity.isfav,
    );

    await updatePassword(updatedEntity);

    _allPasswords = _allPasswords.map((p) {
      return p.id == updatedEntity.id ? updatedEntity : p;
    }).toList();

    _emitFiltered(emit);
  }

  void _onFilter(
      FilterPasswords event,
      Emitter<PasswordState> emit,
      ) {
    _showFavoritesOnly = event.showFavoritesOnly;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<PasswordState> emit) {
    final list = _showFavoritesOnly
        ? _allPasswords.where((p) => p.isfav).toList()
        : _allPasswords;

    // emit(list.isEmpty ? PasswordEmpty() : PasswordLoaded(list));
    if (list.isEmpty) {
      emit(PasswordEmpty(isFiltered: _showFavoritesOnly));
    } else {
      emit(PasswordLoaded(list));
    }
  }

}
