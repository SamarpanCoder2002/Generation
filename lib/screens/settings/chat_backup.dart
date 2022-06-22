// import 'package:flutter/material.dart';
// import 'package:generation/config/colors_collection.dart';
// import 'package:generation/screens/common/button.dart';
// import 'package:provider/provider.dart';
//
// import '../../config/text_style_collection.dart';
// import '../../providers/theme_provider.dart';
//
// class ChatBackupSettingsScreen extends StatefulWidget {
//   const ChatBackupSettingsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChatBackupSettingsScreen> createState() =>
//       _ChatBackupSettingsScreenState();
// }
//
// class _ChatBackupSettingsScreenState extends State<ChatBackupSettingsScreen> {
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
//           child: Column(
//             children: [
//               ListTile(
//                 title: Text(
//                   "Backup",
//                   style: TextStyleCollection.terminalTextStyle
//                       .copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
//                 ),
//                 subtitle: Text(
//                   "Stored Data Will Be End-To-End-Encypted",
//                   style: TextStyleCollection.terminalTextStyle.copyWith(
//                       color: _isDarkMode?AppColors.pureWhiteColor.withOpacity(0.8):AppColors.lightLatestMsgTextColor),
//                 ),
//                 trailing:
//                     commonElevatedButton(btnText: "Start", onPressed: () {}, bgColor: AppColors.getElevatedBtnColor(_isDarkMode)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
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
//               icon: Icon(Icons.arrow_back_outlined,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor)),
//           Text(
//             "Backup Settings",
//             style:
//             TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
//           ),
//         ],
//       ),
//     );
//   }
// }
