enum ChatMessageType{
  text,
  audio,
  image,
  video,
  document,
  location,
  contact,
}

enum ConnectionType{
  available,
  request,
  send
}

enum ThemeModeTypes{
  systemMode,
  lightMode,
  darkMode
}

enum MessageHolderType{
  me,
  other
}

enum ImageType{
  file,
  network,
  asset
}

enum ActivityType{
  text,
  image,
  video,
  audio,
  poll,
}

enum ToastIconType{
  info,
  success,
  error,
  warning
}

enum WallpaperType{
  bright,
  dark,
  solidColor,
  myPhotos
}

enum CommonRequirement{
  chatHistory,
  normal,
  localDataStorage
}