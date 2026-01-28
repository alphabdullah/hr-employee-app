import 'package:flutter/material.dart';

/// Utility class for responsive design that helps maintain consistent UI
/// across different screen sizes by converting design units to actual screen units.
class ScreenUnitUtil {
  static MediaQueryData? _mediaQueryData;
  static double? _screenWidth;
  static double? _screenHeight;
  static double? _blockSizeHorizontal;
  static double? _blockSizeVertical;
  
  // Design reference dimensions (typically based on a standard design size)
  static const double _designWidth = 375.0; // iPhone X/11/12 standard width
  static const double _designHeight = 812.0; // iPhone X/11/12 standard height
  
  /// Initialize ScreenUnitUtil with MediaQuery
  /// Should be called once in the app initialization
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData!.size.width;
    _screenHeight = _mediaQueryData!.size.height;
    _blockSizeHorizontal = _screenWidth! / 100;
    _blockSizeVertical = _screenHeight! / 100;
  }
  
  /// Get responsive width based on design width
  /// Usage: width: ScreenUnitUtil.getWidth(100) for 100 design units
  static double getWidth(double designWidth) {
    if (_screenWidth == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return (designWidth / _designWidth) * _screenWidth!;
  }
  
  /// Get responsive height based on design height
  /// Usage: height: ScreenUnitUtil.getHeight(100) for 100 design units
  static double getHeight(double designHeight) {
    if (_screenHeight == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return (designHeight / _designHeight) * _screenHeight!;
  }
  
  /// Get responsive font size based on design width
  /// Usage: fontSize: ScreenUnitUtil.getFontSize(16) for 16 design units
  static double getFontSize(double designFontSize) {
    if (_screenWidth == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return (designFontSize / _designWidth) * _screenWidth!;
  }
  
  /// Get responsive spacing/padding based on design width
  /// Usage: padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16))
  static double getSpacing(double designSpacing) {
    return getWidth(designSpacing);
  }
  
  /// Get screen width
  static double get screenWidth {
    if (_screenWidth == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return _screenWidth!;
  }
  
  /// Get screen height
  static double get screenHeight {
    if (_screenHeight == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return _screenHeight!;
  }
  
  /// Get block size horizontal (1% of screen width)
  static double get blockSizeHorizontal {
    if (_blockSizeHorizontal == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return _blockSizeHorizontal!;
  }
  
  /// Get block size vertical (1% of screen height)
  static double get blockSizeVertical {
    if (_blockSizeVertical == null) {
      throw Exception('ScreenUnitUtil not initialized. Call init() first.');
    }
    return _blockSizeVertical!;
  }
  
  /// Check if device is tablet
  static bool get isTablet {
    if (_screenWidth == null) {
      return false;
    }
    return _screenWidth! >= 600;
  }
  
  /// Check if device is phone
  static bool get isPhone {
    return !isTablet;
  }
  
  /// Get responsive value that scales between phone and tablet
  static double getResponsiveValue({
    required double phone,
    double? tablet,
  }) {
    if (isTablet && tablet != null) {
      return tablet;
    }
    return phone;
  }
}

