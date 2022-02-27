import 'package:generation/providers/messages_screen_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providersCollection = [
  ChangeNotifierProvider(create: (_) => MessageScreenScrollingProvider())
];
