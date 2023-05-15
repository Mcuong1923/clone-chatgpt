import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Param {
  String name;
  dynamic value;

  Param(this.name, this.value);

  @override
  String toString() {
    return '{ $name, $value }';
  }
}

class ChatGPTApi {
  String apiKey;
  ChatGPTApi({required this.apiKey});

  Uri getUrl() {
    return Uri.https("api.openai.com", "/v1/completions");
  }

  Future<String> complete(
    String prompt, {
    int maxTokens = 2000,
    num temperature = 0,
    num? topP,
    num? frequencyPenalty,
    num? presencePenalty,
    int? n,
    bool? stream,
    String? stop,
    int? logProbs,
    bool? echo,
  }) async {
    String apiKey = this.apiKey;
    List<Param> data = [];
    data.add(Param('temperature', temperature));
    data.add(Param('top_p', topP));
    data.add(Param('frequency_penalty', frequencyPenalty));
    data.add(Param('presence_penalty', presencePenalty));
    data.add(Param('n', n));
    data.add(Param('stream', stream));
    data.add(Param('stop', stop));
    data.add(Param('logprobs', logProbs));
    data.add(Param('echo', echo));
    Map mapNullable = {for (var e in data) e.name: e.value};
    mapNullable.removeWhere((key, value) => key == null || value == null);
    Map mapNotNull = {
      "prompt": prompt,
      'model': 'text-davinci-003',
      "max_tokens": maxTokens,
    };
    Map reqData = {...mapNotNull, ...mapNullable};
    var response = await http.post(
      getUrl(),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $apiKey",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: jsonEncode(reqData),
    );
    if (response.statusCode != 200) {
      if (response.statusCode == 429) {
        throw Exception('Rate limited');
      } else {
        throw Exception('Failed to send message');
      }
    } else if (_errorMessages.contains(response.body)) {
      throw Exception('OpenAI returned an error');
    }
    Map<String, dynamic> newresponse = jsonDecode(
      
      utf8.decode(response.bodyBytes),
    );

    if (newresponse['error'] != null) {
      throw Exception(newresponse['error']['message']);
    } else {
      return newresponse['choices'][0]['text'];
    }
  }
}

const _errorMessages = [
  "{\"detail\":\"Hmm...something seems to have gone wrong. Maybe try me again in a little bit.\"}",
];