# flutter_boost_platform_interface

A common platform interface for the flutter_boost plugin.

This package provides the common platform interface that platform implementations
must implement to support the flutter_boost plugin.

## Usage

This package is not intended to be used directly by application developers.
Instead, use the `flutter_boost` package, which internally uses this interface.

## Extending

Platform implementations should extend `FlutterBoostPlatform` rather than
implement it, as newly added methods to the interface are not considered
breaking changes.
