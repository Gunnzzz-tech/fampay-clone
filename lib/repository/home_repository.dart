import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_model.dart';

class HomeRepository {
  final String apiUrl =
      "https://polyjuice.kong.fampay.co/mock/famapp/feed/home_section/?slugs=famx-paypage";

  Future<HomeModel> fetchHomeData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return HomeModel.fromJson(jsonBody);
    } else {
      throw Exception("Failed to load home data");
    }
  }
}
