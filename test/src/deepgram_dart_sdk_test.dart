// ignore_for_file: prefer_const_constructors
import 'package:deepgram_dart_sdk/deepgram_dart_sdk.dart';
import 'package:deepgram_dart_sdk/src/deepgram_constants.dart';
import 'package:deepgram_dart_sdk/src/exceptions/deepgram_exceptions.dart';
import 'package:deepgram_dart_sdk/src/models/models.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

const apiKeyTest = 'api_key_test';

class MockDio extends Mock implements Dio {
  @override
  BaseOptions get options => BaseOptions(
        baseUrl: deepgramBaseUrl,
        headers: {
          'Authorization': 'Token $apiKeyTest',
        },
      );
}

void main() {
  late final Dio dio;
  late final Deepgram deepgram;
  const tProjectId = 'project_id';
  final tProjectModel = Project(
    projectId: tProjectId,
    name: 'name',
    company: 'company',
  );

  setUpAll(() {
    dio = MockDio();
    deepgram = Deepgram(apiKey: apiKeyTest, dio: dio);
  });

  group('Deepgram', () {
    test('can be instantiated', () {
      expect(Deepgram(apiKey: 'api_key'), isNotNull);
    });

    group('Project endpoint', () {
      test('should return a proyects list', () async {
        when(() => dio.get<Map<String, dynamic>>(projectEndpoint)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: projectEndpoint),
            data: {
              'projects': [
                tProjectModel.toJson(),
              ]
            },
            statusCode: 200,
          ),
        );

        final proyects = await deepgram.getProyects();

        expect(proyects, isA<List<Project>>());
        expect(proyects.length, equals(1));
        expect(dio.options.baseUrl, equals(deepgramBaseUrl));
      });

      test('should throw an exception', () async {
        when(() => dio.get<Map<String, dynamic>>(projectEndpoint)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: projectEndpoint),
            data: {
              'projects': [
                tProjectModel.toJson(),
              ]
            },
            statusCode: 400,
          ),
        );

        expect(deepgram.getProyects, throwsA(isA<DeepgramException>()));
      });

      test('should return a project by id', () async {
        when(
          () => dio.get<Map<String, dynamic>>('$projectEndpoint/$tProjectId'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: '$projectEndpoint/$tProjectId'),
            data: tProjectModel.toJson(),
            statusCode: 200,
          ),
        );

        final proyect = await deepgram.getProjectById(tProjectId);

        expect(proyect, isA<Project>());
        expect(proyect, equals(tProjectModel));

        verify(
          () => dio.get<Map<String, dynamic>>('$projectEndpoint/$tProjectId'),
        ).called(1);
      });

      test('should throw [DeepgramNotFoundException] whend status code is 404',
          () async {
        when(
          () => dio.get<Map<String, dynamic>>('$projectEndpoint/$tProjectId'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: '$projectEndpoint/$tProjectId'),
            data: tProjectModel.toJson(),
            statusCode: 404,
          ),
        );

        expect(
          () => deepgram.getProjectById(tProjectId),
          throwsA(
            isA<DeepgramNotFoundException>().having(
              (e) => e.message,
              'message',
              equals('A project with the specified ID was not found.'),
            ),
          ),
        );
      });

      test('should return a meessage when is update the project properties',
          () async {
        when(
          () => dio.patch<Map<String, dynamic>>(
            '$projectEndpoint/$tProjectId',
            data: {
              'name': tProjectModel.name,
              'company': tProjectModel.company,
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: '$projectEndpoint/$tProjectId'),
            data: {
              'message': 'Project updated successfully.',
            },
            statusCode: 200,
          ),
        );

        expect(
          deepgram.updateProjectById(
            tProjectId,
            name: tProjectModel.name,
            company: tProjectModel.company,
          ),
          completion(equals('Project updated successfully.')),
        );
      });

      test('should return [true] when the project is deleted', () async {
        when(
          () =>
              dio.delete<Map<String, dynamic>>('$projectEndpoint/$tProjectId'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: '$projectEndpoint/$tProjectId'),
            data: {
              'message': 'Project deleted successfully.',
            },
            statusCode: 200,
          ),
        );

        expect(
          deepgram.deleteProjectById(tProjectId),
          completion(isTrue),
        );
      });
    });
  });
}
