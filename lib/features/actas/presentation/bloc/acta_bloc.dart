import 'package:flutter_bloc/flutter_bloc.dart';
import 'acta_event.dart';
import 'acta_state.dart';
import '../../domain/usecases/create_acta.dart';
import '../../domain/usecases/obtener_actas.dart';
import '../../domain/usecases/actualizar_acta.dart';

class ActaBloc extends Bloc<ActaEvent, ActaState> {
  final CrearActa crearActa;
  final ObtenerActas obtenerActas;
  final ActualizarActa actualizarActa;

  ActaBloc({
    required this.crearActa,
    required this.obtenerActas,
    required this.actualizarActa,
  }) : super(ActaInitial()) {

    on<CrearActaEvent>((event, emit) async {
      emit(ActaLoading());
      try {
        await crearActa(event.acta, fotoLocalPath: event.fotoLocalPath);
        emit(ActaSuccess());
      } catch (e) {
        emit(ActaError(e.toString()));
      }
    });

    on<CargarActasEvent>((event, emit) async {
      emit(ActaLoading());
      try {
        final actas = await obtenerActas(userId: event.userId);
        emit(ActasLoaded(actas));
      } catch (e) {
        emit(ActaError(e.toString()));
      }
    });

    on<ActualizarActaEvent>((event, emit) async {
      emit(ActaLoading());
      try {
        await actualizarActa(event.id, event.acta);
        emit(ActaSuccess());
      } catch (e) {
        emit(ActaError(e.toString()));
      }
    });
  }
}
