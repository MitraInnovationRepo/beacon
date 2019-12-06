import 'dart:convert';
import 'package:freewifi/models/dealdata.dart';
import 'package:http/http.dart' as http;



class DealServices {
  static String _url = "http://www.mocky.io/v2/5d639d853200007000ba1c01";
  static Future browse() async {
    http.Response response = await http.get(_url);

    String content = response.body;
    List collection = json.decode(content);
    List<Dealdata> _dealData =
        collection.map((json) => Dealdata.fromJson(json)).toList();

    return _dealData;
  }
}
