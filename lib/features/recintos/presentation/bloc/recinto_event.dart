import '../../domain/entities/recinto.dart';

abstract class RecintoEvent {}

class CrearRecintoEvent extends RecintoEvent {
  final Recinto recinto;
  CrearRecintoEvent(this.recinto);
}

class CargarRecintosEvent extends RecintoEvent {}

class AsignarCoordinadorEvent extends RecintoEvent {
  final String recintoId;
  final String userId;
  AsignarCoordinadorEvent(this.recintoId, this.userId);
}
