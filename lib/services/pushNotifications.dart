import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show Client;
import 'package:my_cab/constance/global.dart';

Client client = Client();

class OneSignalPush {
  Future sendNotification(BuildContext context, List<String> userIds, String message, String heading) async {
    String url = oneSignalPostUrl;

    try {
      final response = await client.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Basic $oneSignalRestApiKey",
          },
          body: jsonEncode(
            {
              "app_id": oneSignalAppId,
              // "included_segments": ["Subscribed Users"],
              "include_external_user_ids": userIds,
              "channel_for_external_user_ids": "push",
              "data": {"foo": "bar"},
              "contents": {"en": message},
              "headings": {"en": heading},
              "android_sound": "neworder.mp3",
              "android_channel_id":channelId
            },
          ));
      final Map result = json.decode(response.body);
      print(response.body);
      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Message Placed');
        print(result);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
