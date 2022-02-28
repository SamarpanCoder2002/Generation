import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/messages_screen_controller.dart';
import '../../types/types.dart';
import '../common/chat_connections_common_design.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {

  @override
  void initState() {
    Provider.of<MessageScreenScrollingProvider>(context, listen: false)
        .startListening();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _groupScreenController =
    Provider.of<MessageScreenScrollingProvider>(context)
        .getScrollController();

    final _commonChatLayout = CommonChatListLayout(providerType: ProviderType.groupChat, context: context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Groups", style: TextStyleCollection.secondaryHeadingTextStyle,),
              ),
              Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height / 1.1,
                margin: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _groupScreenController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: Provider.of<ConnectionCollectionProvider>(context).getDataLength(),
                  itemBuilder: (_, groupIndex)=>  _commonChatLayout.particularChatConnection(groupIndex),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
