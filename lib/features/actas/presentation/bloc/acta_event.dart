import '../../domain/entities/acta.dart';

abstract class ActaEvent {}

class CrearActaEvent extends ActaEvent {
  final Acta acta;
  CrearActaEvent(this.acta);
}

class CargarActasEvent extends ActaEvent {}