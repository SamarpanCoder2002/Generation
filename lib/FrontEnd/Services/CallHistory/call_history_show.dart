import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ShowCallLogsData extends StatefulWidget {
  final String userName;

  ShowCallLogsData(this.userName);

  @override
  _ShowCallLogsDataState createState() => _ShowCallLogsDataState();
}

class _ShowCallLogsDataState extends State<ShowCallLogsData> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  List<Map<String, String>> _callHistoryCollection = [];

  void _getCallHistory() async {
    final List<Map<String, Object>> _tempCollection = await _localStorageHelper
        .countOrExtractTotalCallLogs(widget.userName, purpose: '*');

    print(_tempCollection);

    _tempCollection.forEach((everyHistoryMap) {
      if (everyHistoryMap['__callType__'] ==
          'CallTypes.AudioCall') if (mounted) {
        String _time = everyHistoryMap['__callTime__'].toString();

        _time = '${_time.split(':')[0]}:${_time.split(':')[1]}';

        setState(() {
          this._callHistoryCollection.add({
            '${everyHistoryMap['__callDate__']} $_time':
                everyHistoryMap['__callType__'],
          });
        });
      }
    });
  }

  @override
  void initState() {
    _getCallHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        leading: null,
        title: Text(
          'Call History',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: this._callHistoryCollection.length > 0
            ? ListView.builder(
                itemCount: this._callHistoryCollection.length,
                itemBuilder: (context, position) {
                  return _historyCallLogsList(position);
                },
              )
            : Center(
                child: Text(
                  'No Call History Found',
                  style: TextStyle(color: Colors.red, fontSize: 18.0),
                ),
              ),
      ),
    );
  }

  Widget _historyCallLogsList(int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            this
                ._callHistoryCollection[index]
                .keys
                .first
                .toString()
                .split(' ')[0],
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Text(
            this
                ._callHistoryCollection[index]
                .keys
                .first
                .toString()
                .split(' ')[1],
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          this._callHistoryCollection[index].values.first.toString() ==
                  CallTypes.AudioCall.toString()
              ? Icon(Icons.phone, color: Colors.green, size: 25.0)
              : Icon(Icons.video_call_outlined,
                  color: Colors.green, size: 25.0),
        ],
      ),
    );
  }
}
