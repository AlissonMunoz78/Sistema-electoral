import '../../domain/entities/recinto.dart';

abstract class RecintoState {}

class RecintoInitial extends RecintoState {}

class RecintoLoading extends RecintoState {}

class RecintoSuccess extends RecintoState {}

class RecintosLoaded extends RecintoState {
  final List<Recinto> recintos;
  RecintosLoaded(this.recintos);
}

class RecintoError extends RecintoState {
  final String message;
  RecintoError(this.message);
}
