class NetworkException implements Exception {
  final String message;
  
  NetworkException([this.message = 'Network connection failed.']);
  
  @override
  String toString() => 'NetworkException: $message';
}
