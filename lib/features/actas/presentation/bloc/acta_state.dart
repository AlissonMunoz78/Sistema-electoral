import '../../domain/entities/acta.dart';

abstract class ActaState {}

class ActaInitial extends ActaState {}

class ActaLoading extends ActaState {}

class ActaSuccess extends ActaState {}

class ActasLoaded extends ActaState {
  final List<Acta> actas;
  ActasLoaded(this.actas);
}

class ActaError extends ActaState {
  final String message;
  ActaError(this.message);
}