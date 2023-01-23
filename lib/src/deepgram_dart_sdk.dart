import 'package:deepgram_dart_sdk/src/deepgram_constants.dart';
import 'package:deepgram_dart_sdk/src/exceptions/deepgram_exceptions.dart';
import 'package:deepgram_dart_sdk/src/models/models.dart';
import 'package:dio/dio.dart';

/// {@template deepgram_dart_sdk}
/// Dart SDK for Deepgram's automated speech recognition APIs.
/// {@endtemplate}

class Deepgram {
  /// {@macro deepgram_dart_sdk}
  Deepgram({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: deepgramBaseUrl,
                headers: {
                  'Authorization': 'Token $apiKey',
                },
              ),
            );

  /// The API key for the Deepgram account
  ///
  /// You can [create a Deepgram API Key in the Deepgram Console](https://developers.deepgram.com/documentation/getting-started/authentication/).
  /// You must create your first API Key using the Console.
  final String apiKey;

  final Dio _dio;

  /// Returns a list of all the projects in your account.
  Future<List<Project>> getProyects() async {
    final response = await _dio.get<Map<String, dynamic>>('/projects');

    if (response.statusCode == 200) {
      final projects =
          List<Map<String, dynamic>>.from(response.data!['projects'] as List);

      return projects.map(Project.fromJson).toList();
    } else {
      throw DeepgramException('Failed to get projects');
    }
  }

  /// Return a specific project by ID.
  Future<Project> getProjectById(String projectId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/projects/$projectId');

    if (response.statusCode == 200) {
      return Project.fromJson(response.data!);
    } else {
      if (response.statusCode == 404) {
        throw DeepgramNotFoundException();
      } else {
        throw DeepgramException('Failed to get project');
      }
    }
  }

  /// Updates the specified project.
  Future<String> updateProjectById(
    String projectId, {
    String? name,
    String? company,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '$projectEndpoint/$projectId',
      data: {
        if (name != null) 'name': name,
        if (company != null) 'company': company,
      },
    );

    if (response.statusCode == 200) {
      return response.data!['message'] as String;
    } else {
      throw DeepgramException('Failed to update project');
    }
  }

  /// Deletes the specified project.
  Future<bool> deleteProjectById(String projectId) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '$projectEndpoint/$projectId',
    );

    if (response.statusCode != 200) {
      throw DeepgramException('Failed to delete project');
    }

    return true;
  }
}
