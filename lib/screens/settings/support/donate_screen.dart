// import 'package:flutter/material.dart';
// import 'package:generation/config/colors_collection.dart';
// import 'package:generation/config/text_collection.dart';
// import 'package:generation/services/local_data_management.dart';
// import 'package:generation/services/toast_message_show.dart';
// import 'package:generation/config/types.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import '../../../config/text_style_collection.dart';
// import '../../../providers/theme_provider.dart';
// import '../../../services/debugging.dart';
// import '../../common/button.dart';
//
// class DonateScreen extends StatefulWidget {
//   final bool showMsgFromTop;
//
//   const DonateScreen({Key? key, this.showMsgFromTop = false}) : super(key: key);
//
//   @override
//   State<DonateScreen> createState() => _DonateScreenState();
// }
//
// class _DonateScreenState extends State<DonateScreen> {
//   final TextEditingController _donateController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final Razorpay _razorpay = Razorpay();
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     debugShow(
//         'Success:                        PaymentId: ${response.paymentId}    OrderId: ${response.orderId}         Signature: ${response.signature}');
//     showToast(
//         title: "Payment Successful... Thank You 💖",
//         toastIconType: ToastIconType.success,
//         toastDuration: 10,
//         showFromTop: widget.showMsgFromTop);
//     Navigator.pop(context);
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugShow('Error: ${response.message}');
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugShow('For External Wallet: ${response.walletName}');
//   }
//
//   @override
//   void initState() {
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _donateController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
//
//     return Scaffold(
//       appBar: _headerSection(),
//       backgroundColor: AppColors.getBgColor(_isDarkMode),
//       body: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 _donateAmount(),
//
//                 ///_submitProblem(),
//                 _notAcceptingDonation(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   _donateAmount() {
//     final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
//
//     return Container(
//       margin: const EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 20),
//       child: TextFormField(
//         autofocus: true,
//         controller: _donateController,
//         style: TextStyleCollection.terminalTextStyle.copyWith(
//             fontSize: 14,
//             color: _isDarkMode
//                 ? AppColors.pureWhiteColor
//                 : AppColors.lightChatConnectionTextColor),
//         cursorColor: _isDarkMode
//             ? AppColors.pureWhiteColor
//             : AppColors.lightLatestMsgTextColor,
//         maxLines: null,
//         keyboardType: TextInputType.number,
//         validator: (inputVal) {
//           if (inputVal == null || inputVal.isEmpty) {
//             return "Please Write Donate Amount";
//           }
//           if (int.parse(inputVal) < 20) {
//             return "Donation Amount At Least 20 INR";
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           alignLabelWithHint: true,
//           labelText: "Donation Amount",
//           labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
//               fontSize: 14,
//               color: _isDarkMode
//                   ? AppColors.pureWhiteColor.withOpacity(0.6)
//                   : AppColors.lightLatestMsgTextColor),
//           enabledBorder: UnderlineInputBorder(
//               borderSide: BorderSide(
//                   color: _isDarkMode
//                       ? AppColors.pureWhiteColor
//                       : AppColors.lightChatConnectionTextColor)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(
//                   color: _isDarkMode
//                       ? AppColors.pureWhiteColor
//                       : AppColors.lightChatConnectionTextColor)),
//         ),
//       ),
//     );
//   }
//
//   _submitProblem() {
//     final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       child: commonElevatedButton(
//           bgColor: AppColors.getElevatedBtnColor(_isDarkMode),
//           btnText: "Donate",
//           onPressed: () async {
//             if (!_formKey.currentState!.validate()) return;
//             _nowDonate();
//             //await _inputOption.sendSupportMail(_subjectController.text, _bodyController.text);
//           }),
//     );
//   }
//
//   _nowDonate() {
//     /// for Production We should use Actual Data for all of the following Fields...
//     /// NOTE: Now That API KEY for Test mode. In production we should use live mode api key...
//
//     var options = {
//       'key': DataManagement.getEnvData(EnvFileKey.rzpAPIKEY),
//       'amount': '${double.parse(_donateController.text) * 100}',
//       'description': 'Donation For Generation Improvement',
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugShow('Razorpay Error is: ${e.toString()}');
//     }
//   }
//
//   _headerSection() {
//     final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
//
//     return AppBar(
//       elevation: 0,
//       backgroundColor: AppColors.getBgColor(_isDarkMode),
//       automaticallyImplyLeading: false,
//       title: Row(
//         children: [
//           IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: Icon(Icons.arrow_back_outlined,
//                   color: _isDarkMode
//                       ? AppColors.pureWhiteColor
//                       : AppColors.lightChatConnectionTextColor)),
//           Text(
//             "Donate For Generation",
//             style: TextStyleCollection.terminalTextStyle.copyWith(
//                 fontSize: 16,
//                 color: _isDarkMode
//                     ? AppColors.pureWhiteColor
//                     : AppColors.lightChatConnectionTextColor),
//           ),
//         ],
//       ),
//     );
//   }
//
//   _notAcceptingDonation() {
//     final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
//
//     return Center(
//       child: Text(
//         'Currently we are not accepting any donation from anyone due to some problem. We will activate that section soon. Thanks for your interest.',
//         style: TextStyleCollection.headingTextStyle.copyWith(
//             fontSize: 18,
//             color: AppColors.chatInfoTextColor(_isDarkMode),
//             fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }
