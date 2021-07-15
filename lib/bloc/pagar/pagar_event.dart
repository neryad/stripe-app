part of 'pagar_bloc.dart';

@immutable
abstract class PagarEvent {}

class OnSeleccionarTarjeta extends PagarEvent {
  final TarjetaCredito tarjetaCredito;
  OnSeleccionarTarjeta(this.tarjetaCredito);
}

class OnDesactivarTarjeta extends PagarEvent {}
