import 'dart:convert';

import 'package:generation/api_collection/constant.dart';
import 'package:http/http.dart' as http;

signInManually(String uid) async{
  final url = "${API.baseUrl}/${API.signIn}";

  print("Url is: $url");

  final result = await _postAPICall(url, body: json.encode({
    "id": uid
  }));

  return result;
}


_postAPICall(String url,
    {required body, Map<String, String>? header}) async {
  final http.Response response =
      await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: body, encoding: Encoding.getByName('utf-8'));

  print("Body: ${response.body}");

  if (response.statusCode == 200) return json.decode(response.body);
}
