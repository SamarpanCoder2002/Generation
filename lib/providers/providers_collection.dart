import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/providers/connection_management_provider.dart';
import 'package:generation/providers/group_collection_provider.dart';
import 'package:generation/providers/common_scroll_controller_provider.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:generation/providers/sound_provider.dart';
import 'package:generation/providers/status_collection_provider.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'connection_management_provider_collection/incoming_request_provider.dart';
import 'connection_management_provider_collection/sent_request_provider.dart';
import 'main_screen_provider.dart';

List<SingleChildWidget> providersCollection = [
  ChangeNotifierProvider(create: (_) => MessageScreenScrollingProvider()),
  ChangeNotifierProvider(create: (_) => StatusCollectionProvider()),
  ChangeNotifierProvider(create: (_) => ConnectionCollectionProvider()),
  ChangeNotifierProvider(create: (_) => MainScreenNavigationProvider()),
  ChangeNotifierProvider(create: (_) => GroupCollectionProvider()),
  ChangeNotifierProvider(create: (_) => ConnectionManagementProvider()),
  ChangeNotifierProvider(create: (_) => AllAvailableConnectionsProvider()),
  ChangeNotifierProvider(create: (_) => RequestConnectionsProvider()),
  ChangeNotifierProvider(create: (_) => SentConnectionsProvider()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => SongManagementProvider()),
  ChangeNotifierProvider(create: (_) => ChatBoxMessagingProvider()),
];
