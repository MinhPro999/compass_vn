class CompassUtils {
  static String getDirectionFromAngle(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'Bắc';
    if (angle >= 22.5 && angle < 67.5) return 'Đông Bắc';
    if (angle >= 67.5 && angle < 112.5) return 'Đông';
    if (angle >= 112.5 && angle < 157.5) return 'Đông Nam';
    if (angle >= 157.5 && angle < 202.5) return 'Nam';
    if (angle >= 202.5 && angle < 247.5) return 'Tây Nam';
    if (angle >= 247.5 && angle < 292.5) return 'Tây';
    if (angle >= 292.5 && angle < 337.5) return 'Tây Bắc';
    return 'Không xác định';
  }
}
