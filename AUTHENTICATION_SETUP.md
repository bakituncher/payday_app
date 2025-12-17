# Google ve Apple Sign-In Kurulum Kılavuzu

## ✅ Tamamlanan Adımlar

1. ✅ Google Sign In ve Apple Sign In paketleri eklendi
2. ✅ Authentication servisi oluşturuldu (`lib/core/services/auth_service.dart`)
3. ✅ Authentication provider'ları oluşturuldu (`lib/core/providers/auth_providers.dart`)
4. ✅ Settings ekranına authentication UI eklendi
5. ✅ iOS ve Android yapılandırmaları güncellendi

## 🔧 Firebase Console Kurulumu (ÖNEMLİ!)

### 1. Firebase Console'a Gidin
- [Firebase Console](https://console.firebase.google.com/) adresine gidin
- Projenizi seçin

### 2. Google Sign-In'i Etkinleştirin

#### iOS için:
1. Firebase Console → Authentication → Sign-in method
2. Google provider'ı etkinleştirin
3. iOS uygulama ayarlarına gidin
4. `GoogleService-Info.plist` dosyasını indirin
5. Dosyayı `ios/Runner/` klasörüne kopyalayın
6. `GoogleService-Info.plist` dosyasını açın ve `REVERSED_CLIENT_ID` değerini bulun
7. `ios/Runner/Info.plist` dosyasında şu satırı bulun:
   ```xml
   <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
   ```
8. `YOUR-REVERSED-CLIENT-ID` kısmını `REVERSED_CLIENT_ID` değeriyle değiştirin

#### Android için:
1. Firebase Console → Project Settings → General
2. Android uygulamanızı ekleyin (eğer yoksa)
   - Package name: `com.codenzi.payday.payday_flutter`
   - SHA-1 sertifikasını ekleyin (aşağıdaki komutu çalıştırın):
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. `google-services.json` dosyasını indirin
4. Dosyayı `android/app/` klasörüne kopyalayın

### 3. Apple Sign-In'i Etkinleştirin (sadece iOS)

1. Firebase Console → Authentication → Sign-in method
2. Apple provider'ı etkinleştirin

#### Apple Developer Portal:
1. [Apple Developer Portal](https://developer.apple.com/account) → Certificates, Identifiers & Profiles
2. Identifiers → App IDs → Uygulamanızı seçin
3. "Sign in with Apple" özelliğini etkinleştirin
4. Kaydet ve değişiklikleri uygula

#### Xcode Ayarları:
1. Xcode'da `ios/Runner.xcworkspace` dosyasını açın
2. Runner → Signing & Capabilities
3. "+ Capability" düğmesine tıklayın
4. "Sign in with Apple" özelliğini ekleyin

## 📝 Test Etme

### iOS Simulator'da Test:
```bash
flutter run -d "iPhone 15 Pro"
```

### Android Emulator'da Test:
```bash
flutter run -d emulator-5554
```

**Not:** Google Sign-In'i test etmek için gerçek cihaz veya SHA-1 sertifikası eklenmiş emulator kullanmanız gerekebilir.

## 🎯 Kullanım

Kullanıcılar Settings ekranında:
1. "Account" bölümünü görecekler
2. Giriş yapmadıysa:
   - "Sign in with Google" butonu görünür
   - iOS/macOS'ta "Sign in with Apple" butonu da görünür
3. Giriş yaptıktan sonra:
   - Profil fotoğrafı ve kullanıcı bilgileri görünür
   - "Sign Out" butonu ile çıkış yapabilirler

## 🔒 Güvenlik Notları

1. **Google Sign-In için:**
   - `google-services.json` ve `GoogleService-Info.plist` dosyalarını git'e commitlemeyin
   - Production'da SHA-1 sertifikalarını mutlaka ekleyin

2. **Apple Sign-In için:**
   - App Store'a yüklemeden önce Apple Developer Portal'da yapılandırmayı tamamlayın
   - Privacy Policy linki ekleyin

## 📱 Platform Desteği

- ✅ iOS (Google + Apple Sign-In)
- ✅ Android (Google Sign-In)
- ✅ macOS (Google + Apple Sign-In)
- ⚠️ Web (ek yapılandırma gerektirir)

## 🐛 Sorun Giderme

### "PlatformException" hatası:
- SHA-1 sertifikasının Firebase Console'a eklendiğinden emin olun
- `google-services.json` dosyasının doğru yerde olduğundan emin olun

### Apple Sign-In çalışmıyor:
- Xcode'da "Sign in with Apple" capability'sinin eklendiğini kontrol edin
- Apple Developer Portal'da bundle ID'nin doğru olduğunu kontrol edin

### iOS'ta Google Sign-In çalışmıyor:
- `REVERSED_CLIENT_ID`'nin Info.plist'e doğru eklendiğini kontrol edin
- `GoogleService-Info.plist` dosyasının Runner klasöründe olduğunu kontrol edin

## 📚 Ek Kaynaklar

- [Firebase Authentication Dokümantasyonu](https://firebase.google.com/docs/auth)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple Flutter Plugin](https://pub.dev/packages/sign_in_with_apple)

