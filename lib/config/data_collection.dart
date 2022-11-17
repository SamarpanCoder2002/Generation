class SliderData {
  static List<dynamic> content = [
    {
      "title": "Welcome To Generation 2.0",
      "subtitle":
          "A Private, Secure, End-to-End Encrypted Messaging app that helps you to connect with your connections without any Ads, promotion. No other third party person, organization, or even Generation Team can't read your messages.",
    },
    {
      "title": "Communicate With Security",
      "subtitle":
          "Chat Messages are End-to-End-Encrypted. No-other third party app or Generation Team can't read your messages.",
    },
    {
      "title": "Connect With Protection",
      "subtitle":
          "Get Connected with send and accept connection request. No fear of experiencing random incoming spamming messages.",
    },
    {
      "title": "Enjoy Free Messaging",
      "subtitle":
          "Send Text, Image, Voice, Video, Document and Audio Messages to your favourite one",
    },
    {
      "title": "Share Moments that Matter",
      "subtitle":
          "Share Your Special Moments With Activity. Upload Images from Gallery or Take Picture of your sweet moment with camera and share with your connections.",
    },
  ];
}

class BgTask {
  static const String deleteOwnActivity = "deleteOwnActivity";
  static const String deleteConnectionsActivity = "deleteConnectionsActivity";

  static Map<String, String> deleteOwnActivityData = <String, String>{
    'task': deleteOwnActivity,
    'taskId': '1',
    'initialDelayInSec': '10',
    'frequencyInMin': '15',
  };

  static Map<String, String> deleteConnectionActivities = <String, String>{
    'task': deleteConnectionsActivity,
    'taskId': '2',
    'initialDelayInSec': '30',
    'frequencyInMin': '15',
  };
}
