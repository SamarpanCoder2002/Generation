import 'package:generation/providers/activity/activity_screen_provider.dart';
import 'package:generation/providers/chat/chat_creation_section_provider.dart';
import 'package:generation/providers/chat/chat_scroll_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/providers/connection_management_provider.dart';
import 'package:generation/providers/contacts_provider.dart';
import 'package:generation/providers/group_collection_provider.dart';
import 'package:generation/providers/main_scrolling_provider.dart';
import 'package:generation/providers/chat/messaging_provider.dart';
import 'package:generation/providers/sound_provider.dart';
import 'package:generation/providers/sound_record_provider.dart';
import 'package:generation/providers/status_collection_provider.dart';
import 'package:generation/providers/storage/storage_provider.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:generation/providers/time_provider.dart';
import 'package:generation/providers/video_management/video_editing_provider.dart';
import 'package:generation/providers/video_management/video_show_provider.dart';
import 'package:generation/providers/wallpaper/wallpaper_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'activity/poll_creator_provider.dart';
import 'activity/poll_show_provider.dart';
import 'connection_management_provider_collection/incoming_request_provider.dart';
import 'connection_management_provider_collection/sent_request_provider.dart';
import 'incoming_data_provider.dart';
import 'main_screen_provider.dart';

List<SingleChildWidget> providersCollection = [
  ChangeNotifierProvider(create: (_) => MainScrollingProvider()),
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
  ChangeNotifierProvider(create: (_) => ChatScrollProvider()),
  ChangeNotifierProvider(create: (_) => SoundRecorderProvider()),
  ChangeNotifierProvider(create: (_) => ContactsProvider()),
  ChangeNotifierProvider(create: (_) => ChatCreationSectionProvider()),
  ChangeNotifierProvider(create: (_) => ActivityProvider()),
  ChangeNotifierProvider(create: (_) => WallpaperProvider()),
  ChangeNotifierProvider(create: (_) => StorageProvider()),
  //ChangeNotifierProvider(create: (_) => VideoEditingProvider()),
  ChangeNotifierProvider(create: (_) => TimeProvider()),
  ChangeNotifierProvider(create: (_) => VideoShowProvider()),
  ChangeNotifierProvider(create: (_) => PollCreatorProvider()),
  ChangeNotifierProvider(create: (_) => PollShowProvider()),
  ChangeNotifierProvider(create: (_) => IncomingDataProvider()),
];
