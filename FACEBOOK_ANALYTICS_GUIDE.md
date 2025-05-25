# Facebook Analytics Integration Guide

## Tổng quan
Ứng dụng La Bàn Đại Việt đã được tích hợp Facebook SDK và Analytics để theo dõi hành vi người dùng và tối ưu hóa quảng cáo.

## Các Events được tracking

### 1. App Lifecycle Events
- **app_install**: Lần đầu cài đặt ứng dụng
- **app_launch**: Mỗi lần mở ứng dụng
- **app_activity**: Khi ứng dụng resume/pause

### 2. Screen View Events
- **home_screen**: Khi người dùng vào màn hình chính
- **basic_compass_screen**: Khi người dùng vào màn hình la bàn cơ bản

### 3. Feature Usage Events
- **compass_usage**: Khi người dùng sử dụng la bàn
- **feature_usage**: Theo dõi việc sử dụng các tính năng cụ thể
- **user_engagement**: Theo dõi tương tác của người dùng

### 4. Compass Specific Events
- **compass_selected**: Khi người dùng chọn loại la bàn
- **compass_direction_change**: Khi hướng la bàn thay đổi
- **session_duration**: Thời gian sử dụng mỗi phiên

### 5. Error Tracking Events
- **user_info_missing**: Khi thiếu thông tin người dùng

## Cách sử dụng Facebook Analytics Service

### Import service
```dart
import 'package:compass_vn/services/facebook_analytics_service.dart';
```

### Các phương thức chính

#### 1. Log custom event
```dart
await FacebookAnalyticsService.logEvent('custom_event_name', {
  'parameter1': 'value1',
  'parameter2': 123,
  'parameter3': true,
});
```

#### 2. Log screen view
```dart
await FacebookAnalyticsService.logScreenView('screen_name');
```

#### 3. Log feature usage
```dart
await FacebookAnalyticsService.logFeatureUsage('feature_name', 
  additionalParams: {'extra_info': 'value'});
```

#### 4. Log user engagement
```dart
await FacebookAnalyticsService.logUserEngagement('action_name',
  additionalParams: {'context': 'value'});
```

#### 5. Log compass usage
```dart
await FacebookAnalyticsService.logCompassUsage();
```

#### 6. Log compass direction
```dart
await FacebookAnalyticsService.logCompassDirection(45.0);
```

## Cấu hình Facebook App

### Facebook App ID: 1010457991232883

### Các file đã được cấu hình:
1. **android/app/build.gradle**: Thêm Facebook SDK dependency
2. **android/app/src/main/res/values/strings.xml**: Khai báo Facebook App ID
3. **android/app/src/main/AndroidManifest.xml**: Cấu hình permissions và metadata
4. **android/app/src/main/kotlin/.../MainActivity.kt**: Khởi tạo Facebook SDK

## Xem dữ liệu Analytics

1. Truy cập [Facebook Analytics Dashboard](https://analytics.facebook.com/)
2. Chọn App ID: 1010457991232883
3. Xem các events trong phần "Events"

## Lưu ý quan trọng

1. **Privacy**: Đảm bảo tuân thủ GDPR và các quy định về privacy
2. **Testing**: Sử dụng Facebook Analytics Debugger để test events
3. **Data Retention**: Facebook giữ dữ liệu analytics trong 2 năm
4. **Rate Limiting**: Tránh gửi quá nhiều events trong thời gian ngắn

## Troubleshooting

### Nếu events không hiển thị:
1. Kiểm tra Facebook App ID đúng chưa
2. Đảm bảo ứng dụng đã được publish trên Google Play
3. Chờ 24-48h để dữ liệu hiển thị
4. Sử dụng Facebook Analytics Debugger

### Debug events:
```bash
adb shell setprop log.tag.FBSDKAnalytics VERBOSE
adb logcat | grep FBSDKAnalytics
```
