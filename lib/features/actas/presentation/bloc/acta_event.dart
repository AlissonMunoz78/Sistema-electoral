import '../../domain/entities/acta.dart';

abstract class ActaEvent {}

class CrearActaEvent extends ActaEvent {
  final Acta acta;
  final String? fotoLocalPath;
  CrearActaEvent(this.acta, {this.fotoLocalPath});
}

class CargarActasEvent extends ActaEvent {
  final String? userId;
  CargarActasEvent({this.userId});
}

class ActualizarActaEvent extends ActaEvent {
  final String id;
  final Acta acta;
  ActualizarActaEvent(this.id, this.acta);
}
