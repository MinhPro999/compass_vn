### **Lộ Trình Chi Tiết Hướng Dẫn AI Agent Tích Hợp Facebook SDK & Thiết Lập Quảng Cáo Ứng Dụng**  

#### **Mục Tiêu**:  
- Tích hợp Facebook SDK vào ứng dụng Android để theo dõi sự kiện và hỗ trợ quảng cáo.  
- Thiết lập chiến dịch quảng cáo trên Meta (Facebook Ads) để tối ưu lượt cài đặt ứng dụng từ Google Play.  

---

## **Bước 1: Chuẩn Bị Ứng Dụng Trên Google Play & Facebook Developer**  
1. **Đăng ký ứng dụng trên Google Play**  
   - Lấy **URL Google Play Store** của ứng dụng (vd: `https://play.google.com/store/apps/details?id=com.hellovietnam.compassapp_vn`).  
   - Lấy **Google Play App ID** (vd: `com.hellovietnam.compassapp_vn`).  

2. **Facebook App ID**  
   - **Facebook App ID** 1010457991232883

---

## **Bước 2: Tích Hợp Facebook SDK Vào Ứng Dụng Android**  
### **2.1. Thêm Facebook SDK vào `build.gradle`**  
- Mở **`build.gradle (Module: app)`** và thêm:  
  ```gradle
  dependencies {
      implementation 'com.facebook.android:facebook-android-sdk:[16.0,17.0)'
  }
  ```
- Đồng bộ dự án (Sync Project).  

### **2.2. Khai Báo Facebook App ID trong `strings.xml`**  
- Mở **`/app/src/main/res/values/strings.xml`** và thêm:  
  ```xml
  <string name="facebook_app_id">1010457991232883</string>
  ```

### **2.3. Cập Nhật `AndroidManifest.xml`**  
- Thêm quyền Internet và khai báo Facebook App ID:  
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  
  <application ...>
      <meta-data 
          android:name="com.facebook.sdk.ApplicationId" 
          android:value="@string/facebook_app_id" />
  </application>
  ```

### **2.4. Thiết Lập Deep Linking (Nếu Cần)**  
- Khai báo **MainActivity** trong `AndroidManifest.xml`:  
  ```xml
  <activity android:name="com.example.myapp.MainActivity">
      <intent-filter>
          <action android:name="android.intent.action.VIEW" />
          <category android:name="android.intent.category.DEFAULT" />
          <category android:name="android.intent.category.BROWSABLE" />
          <data android:scheme="https" android:host="www.example.com" />
      </intent-filter>
  </activity>
  ```
