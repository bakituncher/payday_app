# Para Birimi Sistemi - Profesyonelleştirme Dökümantasyonu

## 📋 Genel Bakış

Payday uygulamasının para birimi sistemi, dünya çapında kullanım için profesyonelleştirilmiştir. `currency_picker` paketi entegre edilerek 150+ para birimi desteği sağlanmıştır.

## 🎯 Yapılan Değişiklikler

### 1. **Yeni Paket Entegrasyonu**
- `currency_picker: ^2.0.21` paketi eklendi
- 150+ para birimi desteği
- Ülke bayrakları
- Arama ve filtreleme özellikleri

### 2. **Yeni Servisler**

#### `CurrencyUtilityService` (`lib/core/services/currency_service.dart`)
```dart
// Para birimi bilgilerini getir
final currencyService = CurrencyUtilityService();
final symbol = currencyService.getSymbol('USD'); // $
final name = currencyService.getName('USD'); // United States Dollar
final flag = currencyService.getFlag('USD'); // 🇺🇸
```

Özellikler:
- Para birimi sembolü alma
- Para birimi adı alma
- Para birimi bayrağı alma
- Miktar formatlama
- Binlik ayırıcılar ile formatlama
- Sembol pozisyonu kontrolü (bazı para birimleri için sembol sonda gelir)

#### `CurrencyFormatter` (`lib/core/utils/currency_formatter.dart`)
Güncellendi ve geliştirildi:
```dart
// Basit formatlama
CurrencyFormatter.format(1234.56, 'USD'); // $1,234.56

// Kompakt formatlama
CurrencyFormatter.formatCompact(1234567, 'USD'); // $1.2M

// Binlik ayırıcılar
CurrencyFormatter.formatWithSeparators(1234.56, 'USD'); // $1,234.56

// Sadece sayı
CurrencyFormatter.formatWithoutSymbol(1234.56); // 1,234.56
```

Özellikler:
- Otomatik ondalık basamak kontrolü (JPY, KRW gibi para birimleri için 0)
- Binlik ayırıcılar
- Kompakt gösterim (K, M)
- Para birimi sembolü, adı ve bayrağı

### 3. **Güncellenen Ekranlar**

#### Onboarding Ekranı
- Profesyonel para birimi seçici
- 150+ para birimi desteği
- Bayraklı görünüm
- Arama özelliği
- Popüler para birimleri hızlı seçim

#### Settings Ekranı
- Yeni para birimi kartı tasarımı
- Bayrak gösterimi
- İnteraktif seçici
- Gerçek zamanlı güncelleme

### 4. **AppConstants Güncellemesi**

Eski sistem kaldırıldı:
```dart
// ❌ Kaldırıldı
static const String currencyUSD = 'USD';
static const Map<String, String> currencySymbols = {...};
static const List<Map<String, String>> currencies = [...];
```

Yeni sistem:
```dart
// ✅ Yeni
static const String defaultCurrency = 'USD';
static const List<String> popularCurrencies = [
  'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 
  'CHF', 'CNY', 'TRY', 'INR',
];
```

## 🌍 Desteklenen Para Birimleri

### Popüler Para Birimleri
- 🇺🇸 USD - US Dollar
- 🇪🇺 EUR - Euro
- 🇬🇧 GBP - British Pound
- 🇯🇵 JPY - Japanese Yen
- 🇦🇺 AUD - Australian Dollar
- 🇨🇦 CAD - Canadian Dollar
- 🇨🇭 CHF - Swiss Franc
- 🇨🇳 CNY - Chinese Yuan
- 🇹🇷 TRY - Turkish Lira
- 🇮🇳 INR - Indian Rupee

### Özel Durumlar

#### Ondalık Basamak Olmayan Para Birimleri
```dart
JPY, KRW, VND, CLP, ISK, HUF, TWD, PYG
// Örnek: ¥1,234 (¥1,234.00 değil)
```

#### Sembol Sonda Gelen Para Birimleri
```dart
TRY, PLN, CZK, SEK, NOK, DKK, HUF, RON, BGN, HRK, RUB, UAH
// Örnek: 1.234,56 ₺
```

## 🔧 Kullanım Örnekleri

### Para Birimi Seçici Göster
```dart
showCurrencyPicker(
  context: context,
  theme: CurrencyPickerThemeData(
    backgroundColor: AppColors.cardWhite,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    // ... diğer stil ayarları
  ),
  favorite: AppConstants.popularCurrencies,
  showFlag: true,
  showCurrencyName: true,
  showCurrencyCode: true,
  onSelect: (Currency currency) {
    setState(() {
      selectedCurrency = currency.code;
    });
  },
);
```

### Para Birimi Bilgisi Al
```dart
final service = CurrencyUtilityService();
final currency = service.findByCode('EUR');

print(currency?.name);    // Euro
print(currency?.symbol);  // €
print(currency?.flag);    // 🇪🇺
print(currency?.code);    // EUR
```

### Miktar Formatla
```dart
// Standart
CurrencyFormatter.format(1234.56, 'USD');
// Çıktı: $1,234.56

// Kompakt
CurrencyFormatter.formatCompact(1234567.89, 'EUR');
// Çıktı: €1.2M

// TRY için (sembol sonda)
CurrencyFormatter.format(1234.56, 'TRY');
// Çıktı: 1,234.56 ₺
```

## 📱 Ekran Görüntüleri

### Onboarding - Para Birimi Seçimi
- Bayraklı büyük kart gösterimi
- Popüler para birimleri chip'leri
- Tıkla ve değiştir özelliği

### Settings - Para Birimi Değiştir
- Mevcut para birimi kartı
- Bayrak ve sembol gösterimi
- "Tap to change" etiketi

## 🎨 Tasarım Özellikleri

- Gradient arka planlar
- Smooth animasyonlar
- Haptic feedback
- Dark mode desteği
- Responsive tasarım

## 📦 Bağımlılıklar

```yaml
dependencies:
  currency_picker: ^2.0.21
  intl: ^0.19.0
```

## 🚀 Gelecek Geliştirmeler

- [ ] Döviz kuru çevirici
- [ ] Birden fazla para birimi desteği
- [ ] Para birimi geçmişi
- [ ] Özel para birimi sembolleri
- [ ] Yerelleştirme (çoklu dil)

## 💡 Best Practices

1. Her zaman `CurrencyUtilityService` kullan
2. Null safety kontrolleri yap
3. Para birimi kodları büyük harf olmalı
4. Formatlama için `CurrencyFormatter` kullan
5. UI'da bayrak gösterimi için `getFlag()` kullan

## 🐛 Bilinen Sorunlar

Yok - Tüm hatalar düzeltildi ✅

## 📝 Notlar

- Para birimi verisi `currency_picker` paketinden gelir
- Offline çalışır
- Güncelleme gerektirmez
- 150+ para birimi hazır

