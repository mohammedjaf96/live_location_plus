class PermissionException implements Exception {
  final String message;
  final bool isGranted;

  PermissionException(this.message, this.isGranted);

  @override
  String toString() => 'PermissionException: $message (Granted: $isGranted)';
}