import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';

/// Mixin providing common screen behaviors
/// Use this mixin to add consistent UI patterns to your State classes
mixin ScreenStateMixin<T extends StatefulWidget> on State<T> {
  /// Show success snackbar
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        action: message.toLowerCase().contains('gagal')
            ? SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              )
            : null,
      ),
    );
  }

  /// Show info snackbar
  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show warning snackbar
  void showWarningSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  Future<void> showErrorDialog({
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  Future<void> showSuccessDialog({
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  Future<void> showLoadingDialog({String message = 'Memuat...'}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Dismiss current dialog
  void dismissDialog() {
    Navigator.of(context).pop();
  }

  /// Show bottom sheet
  Future<R?> showBottomSheet<R>({
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  /// Unfocus keyboard
  void unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Check if keyboard is visible
  bool isKeyboardVisible() {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get screen size
  Size get screenSize => MediaQuery.of(context).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Check if device is in landscape mode
  bool get isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if device is in portrait mode
  bool get isPortrait => MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get theme brightness
  Brightness get brightness => Theme.of(context).brightness;

  /// Check if dark mode is enabled
  bool get isDarkMode => brightness == Brightness.dark;

  /// Get text theme
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Get primary color
  Color get primaryColor => Theme.of(context).colorScheme.primary;

  /// Push new route
  Future<R?> pushRoute<R>(Route<R> route) {
    return Navigator.of(context).push(route);
  }

  /// Push named route
  Future<R?> pushNamedRoute<R>(String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed<R>(routeName, arguments: arguments);
  }

  /// Pop current route
  void popRoute<R>([R? result]) {
    Navigator.of(context).pop(result);
  }

  /// Pop until predicate matches
  void popRouteUntil(RoutePredicate predicate) {
    Navigator.of(context).popUntil(predicate);
  }
}

/// Mixin for ConsumerState with Riverpod
mixin ConsumerScreenStateMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Show success snackbar
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Unfocus keyboard
  void unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }
}
