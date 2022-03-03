import 'package:flutter/material.dart';
import 'package:generation/config/text_style_collection.dart';

class MessagingSection extends StatelessWidget {
  final BuildContext context;
  const MessagingSection({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.2,
      child: Text("Implement ListView Here", style: TextStyleCollection.terminalTextStyle,),
    );
  }
}
