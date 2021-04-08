import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  Future<void> sendMessageToOther(String message, String senderMail) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('generation_users')
        .doc(senderMail)
        .get();

    Map<String, dynamic> senderAllConnections =
        documentSnapshot.get('connections');

    List<dynamic> sendMessageList =
        senderAllConnections[FirebaseAuth.instance.currentUser.email];

    sendMessageList.add(message);

    senderAllConnections[FirebaseAuth.instance.currentUser.email] =
        sendMessageList;

    FirebaseFirestore.instance.doc('generation_users/$senderMail').update({
      'connections': senderAllConnections,
    });
  }
}
