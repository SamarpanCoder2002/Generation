enum ChatMessageType {
  text,
  audio,
  image,
  video,
  document,
  location,
  contact,
}

enum ConnectionType { available, request, send }

enum ThemeModeTypes { systemMode, lightMode, darkMode }

enum MessageHolderType { me, other }

enum ImageType { file, network, asset }

enum VideoType {
  file,
  network,
  asset,
}

enum ActivityContentType {
  text,
  image,
  video,
  audio,
  poll,
}

enum ToastIconType { info, success, error, warning }

enum WallpaperType { bright, dark, solidColor, myPhotos }

enum CommonRequirement {
  chatHistory,
  normal,
  localDataStorage,
  forwardMsg,
  incomingData,
}

enum DBOperation { update, insert }

enum IncomingMediaType { file, image, video }

enum SendMsgStorage { local, remote }

enum UserStatus { online, offline }

enum NotificationType { muted, unMuted }

enum ContentFor { global, particularConnection }

enum AwesomeDialogType { success, error, warning, info }
