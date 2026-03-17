import '../../domain/PasswordEntity.dart';

abstract class PasswordState {}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordLoaded extends PasswordState {
  final List<PasswordEntity> passwords;
  PasswordLoaded(this.passwords);
}

class PasswordEmpty extends PasswordState {
  final bool isFiltered;
  PasswordEmpty({this.isFiltered = false});
}
