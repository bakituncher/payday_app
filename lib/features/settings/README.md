# Settings Feature - Modular Architecture

## 📁 Dizin Yapısı

```
features/settings/
├── screens/
│   └── settings_screen.dart          # Ana ayarlar ekranı (451 satır)
├── controllers/
│   ├── settings_controller.dart      # Settings business logic
│   └── auth_controller.dart          # Authentication business logic
├── models/
│   └── settings_form_data.dart       # Form data model
├── widgets/
│   ├── account_section.dart          # Account ve auth UI
│   ├── premium_card.dart             # Premium card widget
│   ├── income_card.dart              # Gelir ve bakiye form
│   ├── pay_cycle_card.dart           # Ödeme döngüsü seçici
│   ├── payday_card.dart              # Maaş günü seçici
│   ├── theme_card.dart               # Tema seçimi
│   ├── currency_card.dart            # Para birimi seçici
│   ├── section_title.dart            # Section başlık widget
│   └── delete_account_dialog.dart    # Hesap silme dialog
└── utils/
    └── date_picker_dialog.dart       # Tarih seçici utility
```

## 🏗️ Mimari Prensipler

### 1. **Separation of Concerns (Endişelerin Ayrılması)**
- **Controllers**: İş mantığı ve state yönetimi
- **Widgets**: Sadece UI render ve kullanıcı etkileşimi
- **Models**: Veri yapıları
- **Utils**: Yardımcı fonksiyonlar

### 2. **Single Responsibility Principle (Tek Sorumluluk Prensibi)**
Her dosya tek bir sorumluluğa sahip:
- `SettingsController`: Settings CRUD işlemleri
- `AuthController`: Authentication işlemleri
- `AccountSection`: Account UI rendering
- `PremiumCard`: Premium status gösterimi

### 3. **Dependency Injection**
- Riverpod providers üzerinden dependency injection
- Controllers constructor'da `ref` ve `context` alır
- Test edilebilir yapı

### 4. **Reusability (Yeniden Kullanılabilirlik)**
- Her widget bağımsız ve yeniden kullanılabilir
- Props pattern kullanılarak parametrelerle özelleştirme
- Generic utilities (DatePickerDialog)

## 🔧 Kullanım

### Controller Kullanımı

```dart
// Settings controller
final settingsController = SettingsController(ref, context);
await settingsController.saveSettings(formData);

// Auth controller
final authController = AuthController(ref, context);
await authController.signInWithGoogle();
```

### Widget Kullanımı

```dart
// Account section
AccountSection(
  isFullyAuthenticated: true,
  currentUser: user,
  onGoogleSignIn: () => handleGoogleSignIn(),
  onSignOut: () => handleSignOut(),
)

// Premium card
const PremiumCard()  // Otomatik premium durumu kontrol eder

// Income card
IncomeCard(
  incomeController: controller,
  currentBalanceController: balanceController,
  selectedCurrency: 'USD',
)
```

## ✅ Avantajlar

### Bakım Kolaylığı
- **1558 satır → 451 satır** (Ana ekran %71 azalma)
- Her bileşen kendi dosyasında
- Değişiklikler tek bir yerde yapılır

### Test Edilebilirlik
- Controllers ayrı test edilebilir
- Widgets mock data ile test edilebilir
- Business logic UI'dan bağımsız

### Ölçeklenebilirlik
- Yeni özellik eklemek kolay
- Yeni widget eklemek mevcut kodu etkilemez
- Team çalışmasına uygun

### Okunabilirlik
- Her dosya tek bir konsepti temsil eder
- Kod navigasyonu kolay
- Yeni geliştiriciler hızlı adapte olur

## 🎯 Best Practices

### 1. Widget Composition
```dart
// ❌ Kötü: Tek büyük widget
build() {
  return Column(
    children: [
      // 100+ satır kod
    ],
  );
}

// ✅ İyi: Composable widgets
build() {
  return Column(
    children: [
      AccountSection(...),
      PremiumCard(),
      IncomeCard(...),
    ],
  );
}
```

### 2. Controller Pattern
```dart
// ❌ Kötü: Business logic widget içinde
setState(() {
  final repo = ref.read(repoProvider);
  await repo.save();
  ref.invalidate(...);
});

// ✅ İyi: Controller kullan
await _settingsController.saveSettings(formData);
```

### 3. Stateless Where Possible
```dart
// ✅ Stateless widget tercih et
class PremiumCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    return ...;
  }
}
```

## 🔄 Migration Checklist

- [x] Models oluşturuldu (SettingsFormData)
- [x] Controllers oluşturuldu (Settings & Auth)
- [x] Widgets ayrıldı (8 adet widget)
- [x] Utils oluşturuldu (DatePickerDialog)
- [x] Ana ekran refactor edildi
- [x] Hata kontrolleri yapıldı
- [x] Import'lar düzenlendi

## 📊 Metrikler

| Metrik | Öncesi | Sonrası | İyileşme |
|--------|--------|---------|----------|
| Ana ekran satır sayısı | 1558 | 451 | %71 ↓ |
| Dosya sayısı | 1 | 13 | +12 |
| Ortalama dosya boyutu | 1558 | ~120 | %92 ↓ |
| Test edilebilir birim | 1 | 13 | 13x ↑ |

## 🚀 Gelecek İyileştirmeler

1. **Unit Tests**: Her controller için unit test yazılabilir
2. **Widget Tests**: Her widget için test yazılabilir
3. **Error Handling**: Custom error handler service
4. **Validation**: Form validation service eklenebilir
5. **Analytics**: User action tracking eklenebilir

## 📚 Referanslar

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/reading)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

