import 'package:dio/dio.dart';
import 'package:stripe_app/models/payment_intent_response.dart';
import 'package:stripe_app/models/stripe_custom_response.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeService {
  //Singleton
  StripeService._privateContructor();

  static final StripeService _intance = StripeService._privateContructor();

  factory StripeService() {
    return _intance;
  }

  String _paymentApUrl = 'https://api.stripe.com/v1/payment_intents';
  static String _secreteKey = 'sk_test_QHXa0Q9Ps0btqAzcXYWoTg1f';
  String _apiKey = 'pk_test_GR7LjyhiXwN55EchnoxOSeW3';
  final headerOptions = new Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {'Authorization': 'Bearer ${StripeService._secreteKey}'});

  void init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: this._apiKey,
        androidPayMode: 'test',
        merchantId: 'test'));
  }

  Future<StripeCustomResponse> pagarConTeajetaExistente(
      {required String amount,
      required String currency,
      required CreditCard card}) async {
    try {
      final paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card));
      // final res = await _crearPaymentIntent(amount: amount, currency: currency);
      final res = await this._realizarCobro(
          amount: amount, currency: currency, paymentMethod: paymentMethod);
      return res;
      //return StripeCustomResponse(ok: true);
    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }

  Future<StripeCustomResponse> pagarConNuevaTeajeta(
      {required String amount, required String currency}) async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      // final res = await _crearPaymentIntent(amount: amount, currency: currency);
      final res = await this._realizarCobro(
          amount: amount, currency: currency, paymentMethod: paymentMethod);
      return res;
      //return StripeCustomResponse(ok: true);
    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }

  Future<PaymentIntentResponse> pagarConAppleGooglePay(
      {required String amount, required String currency}) async {
    try {
      final newAmout = double.parse(amount) / 100;
      final token = await StripePayment.paymentRequestWithNativePay(
          androidPayOptions: AndroidPayPaymentRequest(
              currencyCode: currency, totalPrice: amount),
          applePayOptions: ApplePayPaymentOptions(
              countryCode: 'US',
              currencyCode: currency,
              items: [
                ApplePayItem(label: 'Super producto 1', amount: '$newAmout')
              ]));

      final paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: CreditCard(token: token.tokenId)));

      final res = await this._realizarCobro(
          amount: amount, currency: currency, paymentMethod: paymentMethod);

      await StripePayment.completeNativePayRequest();

      return res;
    } catch (e) {
      print('Error en intento: ${e.toString()}');
      return PaymentIntentResponse(status: '404');
    }
  }

  Future<PaymentIntentResponse> _crearPaymentIntent(
      {required String amount, required String currency}) async {
    try {
      final dio = new Dio();

      final data = {'amount': amount, 'currency': currency};

      final res =
          await dio.post(_paymentApUrl, data: data, options: headerOptions);

      return PaymentIntentResponse.fromJson(res.data);
    } catch (e) {
      print('Error en intento: ${e.toString()}');
      return PaymentIntentResponse(status: '404');
    }
  }

  Future _realizarCobro(
      {required String amount,
      required String currency,
      required PaymentMethod paymentMethod}) async {
    try {
      final res = await _crearPaymentIntent(amount: amount, currency: currency);

      final paymanetResault = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: res.clientSecret,
              paymentMethodId: paymentMethod.id));

      if (paymanetResault.status == 'succeeded') {
        return StripeCustomResponse(ok: true);
      } else {
        return StripeCustomResponse(
            ok: false, msg: 'Fallo: ${paymanetResault.status}');
      }
    } catch (e) {
      print(e.toString());
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }
}
