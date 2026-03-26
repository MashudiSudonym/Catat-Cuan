import 'failure.dart';

/// Failure for network-related errors (e.g., no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
