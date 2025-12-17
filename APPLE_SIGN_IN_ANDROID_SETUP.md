# Android'de Apple Sign In Kurulumu

Android cihazlarda Apple Sign In özelliğini etkinleştirmek için aşağıdaki adımları tamamlamanız gerekmektedir:

## 1. Firebase Console Ayarları

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. Projenizi seçin
3. **Authentication** > **Sign-in method** bölümüne gidin
4. **Apple** sağlayıcısını bulun ve etkinleştirin
5. Gerekli ayarları yapın:
   - **Services ID** (opsiyonel - web OAuth için gerekli)
   - **OAuth code flow configuration** ayarlarını yapın

## 2. Apple Developer Hesabı Gereksinimleri

Apple Sign In Android'de çalışabilmesi için Apple Developer hesabınızda aşağıdaki ayarları yapmalısınız:

### Services ID Oluşturma
1. [Apple Developer Portal](https://developer.apple.com/account/) adresine gidin
2. **Certificates, Identifiers & Profiles** bölümüne gidin
3. **Identifiers** seçin ve **+** butonuna tıklayın
4. **Services IDs** seçin
5. Yeni bir Services ID oluşturun (örn: `com.yourcompany.payday.service`)
6. **Sign In with Apple** seçeneğini etkinleştirin
7. **Configure** butonuna tıklayın ve aşağıdaki bilgileri girin:
   - **Primary App ID**: iOS uygulamanızın Bundle ID'si
   - **Domains and Subdomains**: Firebase projenizin auth domain'i (örn: `your-project.firebaseapp.com`)
   - **Return URLs**: `https://your-project.firebaseapp.com/__/auth/handler`

### Key Oluşturma
1. **Keys** bölümüne gidin
2. **+** butonuna tıklayarak yeni bir key oluşturun
3. **Sign In with Apple** seçeneğini işaretleyin
4. **Configure** butonuna tıklayın ve Primary App ID'nizi seçin
5. Key'i indirin (`.p8` dosyası) - Bu dosyayı kaybetmeyin!
6. **Key ID**'yi not edin

### Firebase'e Bilgileri Ekleme
1. Firebase Console'da Apple authentication ayarlarına dönün
2. **OAuth code flow configuration** bölümünü genişletin
3. Aşağıdaki bilgileri girin:
   - **Services ID**: Oluşturduğunuz Services ID
   - **Apple Team ID**: Apple Developer hesabınızın Team ID'si
   - **Key ID**: Oluşturduğunuz key'in ID'si
   - **Private Key**: İndirdiğiniz `.p8` dosyasının içeriği

## 3. Kod Değişiklikleri

Kod değişiklikleri zaten yapılmıştır:

✅ `auth_service.dart` - Platform kontrolü kaldırıldı, Android desteği eklendi
✅ `settings_screen.dart` - Runtime'da Apple Sign In kullanılabilirliği kontrol ediliyor

## 4. Test Etme

1. Uygulamayı bir Android cihazda veya emülatörde çalıştırın
2. **Settings** ekranına gidin
3. **Sign in with Apple** butonu görünmelidir (Firebase yapılandırması doğruysa)
4. Butona tıklayın ve Apple kimlik bilgilerinizle giriş yapın

## Sorun Giderme

### Apple Sign In butonu görünmüyor
- Firebase Console'da Apple authentication'ın etkinleştirildiğinden emin olun
- Services ID ve OAuth yapılandırmasının doğru yapıldığından emin olun
- Uygulamayı yeniden başlatın

### "Invalid client" hatası
- Services ID'nin doğru yapılandırıldığından emin olun
- Return URL'in Firebase auth domain ile eşleştiğinden emin olun

### "Invalid grant" hatası
- Apple Developer Portal'da key'in doğru yapılandırıldığından emin olun
- Firebase'deki Key ID ve Private Key'in doğru olduğundan emin olun

## Notlar

- Android'de Apple Sign In, iOS'tan farklı olarak web OAuth akışını kullanır
- Kullanıcı bir web görünümünde Apple giriş sayfasına yönlendirilir
- İlk kez giriş yapan kullanıcılar Apple ID'lerini doğrulamalıdır
- Sonraki girişler daha hızlı olacaktır

