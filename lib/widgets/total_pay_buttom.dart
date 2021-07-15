import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_payment/stripe_payment.dart';

class TotalPayButton extends StatelessWidget {
  const TotalPayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pagarBloc = context.read<PagarBloc>().state;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('${pagarBloc.montoPagar} ${pagarBloc.moneda}',
                  style: TextStyle(fontSize: 20))
            ],
          ),
          BlocBuilder<PagarBloc, PagarState>(
            builder: (context, state) {
              return _BtnPay(state);
            },
          )
          // _BtnPay()
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  final PagarState? state;

  const _BtnPay(this.state);
  @override
  Widget build(BuildContext context) {
    return state!.tarjetaActiva
        ? buildButtonTarjet(context)
        : buildAppleAndGooglePay(context);
  }

  Widget buildButtonTarjet(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.solidCreditCard,
              color: Colors.white,
            ),
            Text(
              '  Pagar',
              style: TextStyle(color: Colors.white, fontSize: 22),
            )
          ],
        ),
        onPressed: () async {
          mostrarLoading(context);
          final stripeService = new StripeService();
          final pagarBlocStare = context.read<PagarBloc>().state;
          final tarjeta = state!.tarjeta;
          final mesAno = tarjeta!.expiracyDate.split('/');

          final res = await stripeService.pagarConTeajetaExistente(
              amount: state!.montoPagarString,
              currency: state!.moneda,
              card: CreditCard(
                  number: tarjeta.cardNumber,
                  expMonth: int.parse(mesAno[0]),
                  expYear: int.parse(mesAno[1])));

          Navigator.pop(context);
          if (res.ok) {
            mostrarAlerta(context, 'Tarjeta OK', 'Todo Correcto');
          } else {
            mostrarAlerta(context, 'Algo salio mal', res.msg ?? '');
          }
        });
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        child: Row(
          children: [
            Icon(
              Platform.isAndroid
                  ? FontAwesomeIcons.google
                  : FontAwesomeIcons.apple,
              color: Colors.white,
            ),
            Text(
              ' Pay',
              style: TextStyle(color: Colors.white, fontSize: 22),
            )
          ],
        ),
        onPressed: () async {
          mostrarLoading(context);
          final stripeService = new StripeService();
          final pagarBlocStare = context.read<PagarBloc>().state;

          final res = await stripeService.pagarConAppleGooglePay(
            amount: pagarBlocStare.montoPagarString,
            currency: pagarBlocStare.montoPagarString,
          );
        });
  }
}
