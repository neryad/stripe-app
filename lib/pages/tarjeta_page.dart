import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/models/tarjeta_credito.dart';
import 'package:stripe_app/widgets/total_pay_buttom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TarjetaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final tarjeta = TarjetaCredito(
    //     cardNumberHidden: '4242',
    //     cardNumber: '4242424242424242',
    //     brand: 'visa',
    //     cvv: '213',
    //     expiracyDate: '01/25',
    //     cardHolderName: 'Fernando Herrera');
    final tarjeta = context.read<PagarBloc>().state.tarjeta;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<PagarBloc>().add(OnDesactivarTarjeta());
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(),
          Hero(
            tag: tarjeta!.cardNumber,
            child: CreditCardWidget(
                cardNumber: tarjeta.cardNumber,
                expiryDate: tarjeta.expiracyDate,
                cardHolderName: tarjeta.cardHolderName,
                cvvCode: tarjeta.cvv,
                showBackView: false),
          ),
          Positioned(
            child: TotalPayButton(),
            bottom: 0,
          ),
        ],
      ),
    );
  }
}
