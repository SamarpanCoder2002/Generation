import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:polls/polls.dart';

class PollsMaker extends StatefulWidget {
  const PollsMaker({Key key}) : super(key: key);

  @override
  _PollsMakerState createState() => _PollsMakerState();
}

class _PollsMakerState extends State<PollsMaker> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center();
  }

// double option1 = 0.0;
// double option2 = 0.1;
// double option3 = 0.05;
// double option4 = 0.11428571428571428571428571428571;
//
// String user = "king@mail.com";
// Map usersWhoVoted = {'sam@mail.com': 1, 'mike@mail.com' : 1, 'john@mail.com' : 1, 'kenny@mail.com' : 1};
// String creator = "eddy@mail.com";
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Container(
//       child: Polls(
//         children: [
//           // This cannot be less than 2, else will throw an exception
//           Polls.options(title: 'Cairo', value: option1),
//           Polls.options(title: 'Mecca', value: option2),
//           Polls.options(title: 'Denmark', value: option3),
//           Polls.options(title: 'Mogadishu', value: option4),
//         ],
//         question: Text('how old are you?'),
//         currentUser: this.user,
//         creatorID: this.creator,
//         voteData: usersWhoVoted,
//         userChoice: usersWhoVoted[this.user],
//         onVoteBackgroundColor: Colors.blue,
//         leadingBackgroundColor: Colors.blue,
//         backgroundColor: Colors.white,
//         onVote: (choice) {
//           print(choice);
//           setState(() {
//             this.usersWhoVoted[this.user] = choice;
//           });
//           if (choice == 1) {
//             setState(() {
//               option1 += 0.1;
//             });
//           }
//           if (choice == 2) {
//             setState(() {
//               option2 += 0.1;
//             });
//           }
//           if (choice == 3) {
//             setState(() {
//               option3 += 0.1;
//             });
//           }
//           if (choice == 4) {
//             setState(() {
//               option4 += 0.1;
//             });
//           }
//         },
//       ),
//     ),
//   );
// }
}
