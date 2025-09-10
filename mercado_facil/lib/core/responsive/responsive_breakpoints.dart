import 'package:flutter/material.dart';

/// Sistema de breakpoints responsivos
class ResponsiveBreakpoints {
  // Breakpoints baseados no Material Design
  static const double mobile = 600; // < 600dp
  static const double tablet = 900; // 600dp - 900dp
  static const double desktop = 1200; // 900dp - 1200dp
  static const double largeDesktop = 1200; // > 1200dp

  // Breakpoints específicos para o app
  static const double smallMobile = 320; // iPhone SE, etc
  static const double mediumMobile = 375; // iPhone 12, etc
  static const double largeMobile = 414; // iPhone 12 Pro Max, etc
  static const double smallTablet = 768; // iPad Mini, etc
  static const double largeTablet = 1024; // iPad Pro, etc

  /// Verifica se é mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Verifica se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Verifica se é large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  /// Verifica se é small mobile
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < smallMobile;
  }

  /// Verifica se é medium mobile
  static bool isMediumMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallMobile && width < mediumMobile;
  }

  /// Verifica se é large mobile
  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mediumMobile && width < largeMobile;
  }

  /// Verifica se é small tablet
  static bool isSmallTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeMobile && width < smallTablet;
  }

  /// Verifica se é large tablet
  static bool isLargeTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallTablet && width < largeTablet;
  }

  /// Obtém o tipo de dispositivo atual
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    if (width < desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Obtém o tamanho específico do dispositivo
  static DeviceSize getDeviceSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < smallMobile) return DeviceSize.smallMobile;
    if (width < mediumMobile) return DeviceSize.mediumMobile;
    if (width < largeMobile) return DeviceSize.largeMobile;
    if (width < smallTablet) return DeviceSize.smallTablet;
    if (width < largeTablet) return DeviceSize.largeTablet;
    if (width < desktop) return DeviceSize.desktop;
    return DeviceSize.largeDesktop;
  }

  /// Obtém a orientação atual
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Verifica se está em modo paisagem
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Verifica se está em modo retrato
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Obtém informações completas do dispositivo
  static DeviceInfo getDeviceInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return DeviceInfo(
      width: mediaQuery.size.width,
      height: mediaQuery.size.height,
      devicePixelRatio: mediaQuery.devicePixelRatio,
      orientation: mediaQuery.orientation,
      deviceType: getDeviceType(context),
      deviceSize: getDeviceSize(context),
    );
  }
}

/// Tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Tamanhos específicos de dispositivo
enum DeviceSize {
  smallMobile,    // < 320dp
  mediumMobile,   // 320dp - 375dp
  largeMobile,    // 375dp - 414dp
  smallTablet,    // 414dp - 768dp
  largeTablet,    // 768dp - 1024dp
  desktop,        // 1024dp - 1200dp
  largeDesktop,   // > 1200dp
}

/// Informações completas do dispositivo
class DeviceInfo {
  final double width;
  final double height;
  final double devicePixelRatio;
  final Orientation orientation;
  final DeviceType deviceType;
  final DeviceSize deviceSize;

  DeviceInfo({
    required this.width,
    required this.height,
    required this.devicePixelRatio,
    required this.orientation,
    required this.deviceType,
    required this.deviceSize,
  });

  @override
  String toString() {
    return 'DeviceInfo(width: $width, height: $height, deviceType: $deviceType, deviceSize: $deviceSize, orientation: $orientation)';
  }
}

/// Mixin para adicionar funcionalidades responsivas
mixin ResponsiveMixin {
  /// Verifica se é mobile
  bool isMobile(BuildContext context) => ResponsiveBreakpoints.isMobile(context);

  /// Verifica se é tablet
  bool isTablet(BuildContext context) => ResponsiveBreakpoints.isTablet(context);

  /// Verifica se é desktop
  bool isDesktop(BuildContext context) => ResponsiveBreakpoints.isDesktop(context);

  /// Obtém tipo de dispositivo
  DeviceType getDeviceType(BuildContext context) => ResponsiveBreakpoints.getDeviceType(context);

  /// Obtém informações do dispositivo
  DeviceInfo getDeviceInfo(BuildContext context) => ResponsiveBreakpoints.getDeviceInfo(context);
} 