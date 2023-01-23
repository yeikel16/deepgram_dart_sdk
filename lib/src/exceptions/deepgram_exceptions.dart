class DeepgramException implements Exception {
  DeepgramException(this.message);
  final String message;
}

class DeepgramNotFoundException extends DeepgramException {
  DeepgramNotFoundException()
      : super('A project with the specified ID was not found.');
}
