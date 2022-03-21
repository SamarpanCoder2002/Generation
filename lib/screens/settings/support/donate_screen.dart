import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../config/text_style_collection.dart';
import '../../common/button.dart';

class DonateScreen extends StatefulWidget {
  final bool showMsgFromTop;
  const DonateScreen({Key? key, this.showMsgFromTop = false}) : super(key: key);

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final TextEditingController _donateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Razorpay _razorpay = Razorpay();

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Success: ${response.paymentId}');
    showToast(context, title: "Payment Successful... Thank You 💖", toastIconType: ToastIconType.success, toastDuration: 10, showFromTop: widget.showMsgFromTop);
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('For External Wallet: ${response.walletName}');
  }

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _donateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _headerSection(),
      backgroundColor: AppColors.backgroundDarkMode,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [_donateAmount(), _submitProblem()],
            ),
          ),
        ),
      ),
    );
  }

  _donateAmount() {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 20),
      child: TextFormField(
        autofocus: true,
        controller: _donateController,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 14, color: AppColors.pureWhiteColor),
        cursorColor: AppColors.pureWhiteColor,
        maxLines: null,
        keyboardType: TextInputType.number,
        validator: (inputVal) {
          if (inputVal == null || inputVal.isEmpty) {
            return "Please Write Donate Amount";
          }
          if (int.parse(inputVal) < 20) {
            return "Donation Amount At Least 20 INR";
          }
          return null;
        },
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: "Donation Amount",
          labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 14, color: AppColors.pureWhiteColor.withOpacity(0.6)),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
        ),
      ),
    );
  }

  _submitProblem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: commonElevatedButton(
          btnText: "Donate",
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            _nowDonate();
            //await _inputOption.sendSupportMail(_subjectController.text, _bodyController.text);
          }),
    );
  }

  _nowDonate() {


    /// for Production We should use Actual Data for all of the following Fields...
    /// NOTE: Now That API KEY for Test mode. In production we should use live mode api key...

    var options = {
      'key': DataManagement.getEnvData(EnvFileKey.rzpAPIKEY),
      'amount': '${int.parse(_donateController.text) * 100}',
      //"currency": "INR",
      'email': "samarpan2dasgupta@gmail.com",
      'name': "Samarpan Dasgupta",
      'description': 'Donation For Improvement',
      'prefill': {'email': "samarpan2dasgupta@gmail.com"}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error is: ${e.toString()}');
    }
  }

  _headerSection() => AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined)),
            Text(
              "Donate For Generation",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );
}
