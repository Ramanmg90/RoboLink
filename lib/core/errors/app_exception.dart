/// Errors raised by the device communication layer. Messages are Persian and
/// safe to show directly to the user.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DeviceUnreachableException extends AppException {
  const DeviceUnreachableException(
      [super.message =
          'دستگاه در دسترس نیست. اتصال وای‌فای گوشی و آدرس IP دستگاه را بررسی کنید.']);
}

class DeviceTimeoutException extends AppException {
  const DeviceTimeoutException(
      [super.message =
          'پاسخی از دستگاه دریافت نشد (پایان مهلت). برق دستگاه و شبکه را بررسی کنید.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'توکن دسترسی نادرست است. توکن را در تنظیمات دستگاه اصلاح کنید.']);
}

class DeviceRejectedException extends AppException {
  const DeviceRejectedException(super.message);
}

class MalformedResponseException extends AppException {
  const MalformedResponseException(
      [super.message =
          'پاسخ دستگاه معتبر نیست. نسخهٔ فریمور و مسیرهای API را بررسی کنید.']);
}

class CommandUnconfirmedException extends AppException {
  const CommandUnconfirmedException(super.message);
}
