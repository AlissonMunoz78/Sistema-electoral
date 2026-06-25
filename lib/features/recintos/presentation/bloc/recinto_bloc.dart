import 'package:flutter_bloc/flutter_bloc.dart';
import 'recinto_event.dart';
import 'recinto_state.dart';
import '../../domain/usecases/crear_recinto.dart';
import '../../domain/usecases/obtener_recintos.dart';
import '../../domain/usecases/asignar_coordinador.dart';

class RecintoBloc extends Bloc<RecintoEvent, RecintoState> {
  final CrearRecinto crearRecinto;
  final ObtenerRecintos obtenerRecintos;
  final AsignarCoordinador asignarCoordinador;

  RecintoBloc({
    required this.crearRecinto,
    required this.obtenerRecintos,
    required this.asignarCoordinador,
  }) : super(RecintoInitial()) {

    on<CrearRecintoEvent>((event, emit) async {
      emit(RecintoLoading());
      try {
        await crearRecinto(event.recinto);
        emit(RecintoSuccess());
      } catch (e) {
        emit(RecintoError(e.toString()));
      }
    });

    on<CargarRecintosEvent>((event, emit) async {
      emit(RecintoLoading());
      try {
        final recintos = await obtenerRecintos();
        emit(RecintosLoaded(recintos));
      } catch (e) {
        emit(RecintoError(e.toString()));
      }
    });

    on<AsignarCoordinadorEvent>((event, emit) async {
      try {
        await asignarCoordinador(event.recintoId, event.userId);
        add(CargarRecintosEvent());
      } catch (e) {
        emit(RecintoError(e.toString()));
      }
    });
  }
}
