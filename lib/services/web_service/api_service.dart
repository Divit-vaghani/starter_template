import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/http.dart';
import 'package:starter_template/model/people_model/people.dart';

part 'api_service.g.dart';

@RestApi(
  baseUrl: "https://61028c7079ed68001748216c.mockapi.io/",
  parser: Parser.FlutterCompute,
)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("/peoples")
  Future<List<PeopleModel>> getPeoples();

  @GET("/users")
  Future<List<PeopleModel>> getUsers();
}


List<PeopleModel> deserializePeopleModelList(List<Map<String, dynamic>> json) {
  return json.map((e) => PeopleModel.fromJson(e)).toList();
}

