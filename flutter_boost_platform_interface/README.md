# flutter_boost_platform_interface

A common platform interface for the `flutter_boost` plugin.

This interface allows platform-specific implementations of the `flutter_boost` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Usage

To implement a new platform-specific implementation of `flutter_boost`, extend `FlutterBoostPlatform` with an implementation that performs the platform-specific behavior.

## Note

This package is not intended for direct use by end users. For the app-facing plugin, see [flutter_boost](https://pub.dev/packages/flutter_boost).
