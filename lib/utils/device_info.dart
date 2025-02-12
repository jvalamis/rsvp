import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop
}

class DeviceInfo {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    
    // Consider device type based on screen width
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) => 
      getDeviceType(context) == DeviceType.mobile;
      
  static bool isTablet(BuildContext context) => 
      getDeviceType(context) == DeviceType.tablet;
      
  static bool isDesktop(BuildContext context) => 
      getDeviceType(context) == DeviceType.desktop;
      
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
} 